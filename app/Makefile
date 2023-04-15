AWS_ACCOUNT=787730458677
PROJECT_NAME=pwh-project

build:
		docker build -t ${PROJECT_NAME} .

tag: build
		docker tag ${PROJECT_NAME}:latest ${AWS_ACCOUNT}.dkr.ecr.us-west-2.amazonaws.com/${PROJECT_NAME}:latest

upload: build tag
		aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin ${AWS_ACCOUNT}.dkr.ecr.us-west-2.amazonaws.com
		docker push ${AWS_ACCOUNT}.dkr.ecr.us-west-2.amazonaws.com/${PROJECT_NAME}:latest