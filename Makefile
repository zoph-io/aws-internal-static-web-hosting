.DEFAULT_GOAL ?= help
.PHONY: help

help:
	@echo "${Project}"
	@echo "${Description}"
	@echo ""
	@echo "Deploy using:"
	@echo "  make deploy - Deploy the stack"
	@echo "  make tear-down - Destroy the stack"

###################### Parameters ######################
# Environment Name
Env := "dev"
# Website / Project Name
Project := "myprojectname"
# Project Description
Description := "aws-internal-static-web-hosting"
# AWS Region were the stack will be deployed
AWSRegion := "eu-west-1"
# Website Domain Name
DomainName := "internal.zoph.io"
# Route53 Hosted ZoneId
HostedZoneId := "Z1BPJ53MJJG818"
# ACM Certificate Arn
ACMCertificateArn := "arn:aws:acm:eu-west-1:123456789121:certificate/2106036f-0ba9-4d59-bf0d-2ee44725adb1"
# VPC Id
VpcId := "vpc-046bb960"
# VPC Cidr Block
VpcCidrBlock := "172.31.0.0/16"
# Private Subnet 1
PrivateSubnetId1 := "subnet-b3e648c5"
# Private Subnet 2
PrivateSubnetId2 := "subnet-40738a18"
#######################################################

infra:
	aws cloudformation deploy \
		--template-file ./template.yml \
		--region ${AWSRegion} \
		--stack-name "${Project}-internal-static-web-hosting-${Env}" \
		--capabilities CAPABILITY_IAM \
		--parameter-overrides \
			pEnv=${Env} \
			pProject=${Project} \
			pDescription="${Description}" \
			pDomainName=${DomainName} \
			pACMCertificateArn=${ACMCertificateArn} \
			pVpcId=${VpcId} \
			pVpcCidrBlock=${VpcCidrBlock} \
			pPrivateSubnetId1=${PrivateSubnetId1} \
			pPrivateSubnetId2=${PrivateSubnetId2} \
			pHostedZoneId=${HostedZoneId} \
		--no-fail-on-empty-changeset

deploy: infra
	@aws s3 cp ./assets/index.html s3://${DomainName}/

tear-down:
	@read -p "Are you sure that you want to destroy stack '${Project}-internal-static-web-hosting-${Env}'? [y/N]: " sure && [ $${sure:-N} = 'y' ]
	@aws s3 rm s3://${DomainName}/index.html
	aws cloudformation delete-stack --stack-name "${Project}-internal-static-web-hosting-${Env}"