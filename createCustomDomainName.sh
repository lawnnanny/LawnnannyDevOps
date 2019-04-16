#!/bin/bash
DOMAIN_PARENT=$1
CERTIFICATE_DOMAIN=$2
CUSTOM_DOMAIN_NAME=$3
echo $DOMAIN_PARENT
echo $CERTIFICATE_DOMAIN
echo $CUSTOM_DOMAIN_NAME
echo "Getting Distribution Hosted Zone ID"
DomainParentHostedZoneID=$(aws route53 list-hosted-zones-by-name --query "(HostedZones[?Name=='${DOMAIN_PARENT}'])[0].Id" --output text)
echo $DomainParentHostedZoneID

domainExists=$(aws apigateway get-domain-names --query "items[?domainName=='${CUSTOM_DOMAIN_NAME}']")
if [ "$domainExists" = "[]" ]; then
    echo "Getting Certificate"
    CertificateArn=$(aws acm list-certificates --query "(CertificateSummaryList[?DomainName=='${CERTIFICATE_DOMAIN}'])[0].CertificateArn" --output text)
    echo $CertificateArn
    echo "Creating Domain Name"
    aws apigateway create-domain-name --domain-name ${CUSTOM_DOMAIN_NAME} --certificate-arn $CertificateArn
fi

echo "Getting Distribution Domain Name"
DistributionDomainName=$(aws apigateway get-domain-names --output text --query "(items[?domainName=='${CUSTOM_DOMAIN_NAME}'])[0].distributionDomainName")
echo $DistributionDomainName

echo "Getting API ID"
apiId=$(aws apigateway get-rest-apis --output text --query "(items[?name=='hello'])[0].id")
echo $apiId

echo "Getting Registration RestApi ID"
RegistrationRestApiId=$(aws apigateway get-rest-apis --output text --query "(items[?name=='Registration'])[0].id")
echo $RegistrationRestApiId

aws cloudformation deploy --stack-name DomainStack \
        --template-file ./domain.yaml \
        --parameter-overrides \
            RestApiId=$apiId \
            DomainParentHostedZoneID=$DomainParentHostedZoneID \
            CustomDomainName=$CUSTOM_DOMAIN_NAME \
            DistributionDomainName=$DistributionDomainName \
            RegistrationRestApi=$RegistrationRestApiId \
        --no-fail-on-empty-changeset \
