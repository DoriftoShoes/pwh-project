AWS_ACCOUNT=
PROJECT_NAME=pwh-project
REGION=us-west-2

build:
		docker build -t ${PROJECT_NAME} .

tag: build
		docker tag ${PROJECT_NAME}:latest ${AWS_ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${PROJECT_NAME}:latest

upload: build tag
		aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin ${AWS_ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com
		docker push ${AWS_ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${PROJECT_NAME}:latest