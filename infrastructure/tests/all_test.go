package test

import (
	"fmt"
	"os/exec"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestAll(t *testing.T) {

	folder := test_structure.CopyTerraformFolderToTemp(t, "../", "pwh-project")

	//awsRegion := aws.GetRandomStableRegion(t, nil, nil)
	awsRegion := "us-west-1"
	projectName := "pwh-project-test-" + random.UniqueId()
	clusterSize := 1
	kubeResourcePath, err := filepath.Abs("kubernetes/nginx.yaml")
	if err != nil {
		fmt.Println(err.Error())
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: folder,

		Vars: map[string]interface{}{
			"region":               awsRegion,
			"vpc_cidr_block":       "10.1.0.0/16",
			"public_subnet_cidrs":  "[\"10.1.1.0/24\", \"10.1.2.0/24\", \"10.1.3.0/24\"]",
			"private_subnet_cidrs": "[\"10.1.4.0/24\", \"10.1.5.0/24\", \"10.1.6.0/24\"]",
			"cluster_name":         projectName,
			"cluster_version":      "1.25",
			"main_instance_types":  "[\"t3.medium\"]",
			"main_size":            fmt.Sprintf("{min: %d, max: %d, desired: %d}", clusterSize, clusterSize, clusterSize),
			"deploy_app":           false,
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	logger.Log(t, "AWS Region: "+awsRegion)
	vpcID := terraform.Output(t, terraformOptions, "vpc_id")
	vpc := aws.GetVpcById(t, vpcID, awsRegion)
	assert.Equal(t, projectName, vpc.Name)

	publicSubnetIds := terraform.OutputList(t, terraformOptions, "public_subnet_ids")
	for i := 0; i < len(publicSubnetIds); i++ {
		isPublic := aws.IsPublicSubnet(t, publicSubnetIds[i], awsRegion)
		assert.True(t, isPublic)

		subnetTags := aws.GetTagsForSubnet(t, publicSubnetIds[i], awsRegion)
		lbTag, containsLbTag := subnetTags["kubernetes.io/role/elb"]
		assert.True(t, containsLbTag)
		assert.Equal(t, "1", lbTag)
	}

	privateSubnetIds := terraform.OutputList(t, terraformOptions, "private_subnet_ids")
	for i := 0; i < len(privateSubnetIds); i++ {
		isPublic := aws.IsPublicSubnet(t, privateSubnetIds[i], awsRegion)
		assert.False(t, isPublic)

		subnetTags := aws.GetTagsForSubnet(t, privateSubnetIds[i], awsRegion)
		lbTag, containsLbTag := subnetTags["kubernetes.io/role/internal-elb"]
		assert.True(t, containsLbTag)
		assert.Equal(t, "1", lbTag)
	}

	logger.Log(t, "AWS Region: "+awsRegion)
	ngInstances := aws.GetEc2InstanceIdsByTag(t, awsRegion, "kubernetes.io/cluster/"+projectName, "owned")
	assert.Equal(t, clusterSize, len(ngInstances))

	for i := 0; i < len(ngInstances); i++ {
		tags := aws.GetTagsForEc2Instance(t, awsRegion, ngInstances[i])
		autoscalerTag, containsAutoscalerTag := tags["k8s.io/cluster-autoscaler/enabled"]
		assert.True(t, containsAutoscalerTag)
		assert.Equal(t, "true", autoscalerTag)
	}

	//cmd := exec.Command("aws", "eks", "get-token", "--cluster-name", projectName)
	cmd := exec.Command("aws", "eks", "update-kubeconfig", "--region", awsRegion, "--name", projectName)
	stdout, err := cmd.Output()

	if err != nil {
		fmt.Println(err.Error())
	}
	logger.Log(t, string(stdout))

	options := k8s.NewKubectlOptions("", "", "default")
	defer k8s.KubectlDelete(t, options, kubeResourcePath)
	k8s.KubectlApply(t, options, kubeResourcePath)

	nodesReady := k8s.AreAllNodesReady(t, options)
	assert.True(t, nodesReady)

	service := k8s.GetService(t, options, "nginx-service")
	serviceAvailable := k8s.IsServiceAvailable(service)
	assert.True(t, serviceAvailable)
}
