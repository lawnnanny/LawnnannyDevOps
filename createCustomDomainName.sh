#!/bin/bash
DOMAIN_PARENT=$0
CERTIFICATE_DOMAIN=$1
CUSTOM_DOMAIN_NAME=$2
echo $DOMAIN_PARENT
echo $CERTIFICATE_DOMAIN
echo $CUSTOM_DOMAIN_NAME
echo "Getting Distribution Hosted Zone ID"
DomainParentHostedZoneID=$(aws route53 list-hosted-zones-by-name --query "(HostedZones[?Name=='${DOMAIN_PARENT}'].Id)[0]" --output text)
echo $DomainParentHostedZoneID

echo "Getting Certificate"
CertificateArn=$(aws acm list-certificates --query "(CertificateSummaryList[?DomainName=='${CERTIFICATE_DOMAIN}'].CertificateArn)[0]" --output text)
echo $CertificateArn

domainExists=$(aws apigateway get-domain-names --query "items[?domainName=='${CUSTOM_DOMAIN_NAME}']")
if [ "$domainExists" = "[]" ]; then
  echo "Creating Domain Name"
  aws apigateway create-domain-name --domain-name ${CUSTOM_DOMAIN_NAME} --certificate-arn $CertificateArn
fi

echo "Getting Distribution Domain Name"
DistributionDomainName=$(aws apigateway get-domain-names --output text --query "(items[?domainName=='${CUSTOM_DOMAIN_NAME}'].distributionDomainName)[0]")

echo "Getting API ID"
apiId=$(aws apigateway get-rest-apis --output text --query "(items[?name=='hello'].id)[0]")
echo $apiId

aws cloudformation deploy --stack-name DomainStack \
        --template-file ./domain.yaml \
        --parameter-overrides \
            RestApiId=$apiId \
            DomainParentHostedZoneID=$DomainParentHostedZoneID \
            CustomDomainName=$CUSTOM_DOMAIN_NAME \
            DistributionDomainName=$DistributionDomainName \
        --no-fail-on-empty-changeset \
