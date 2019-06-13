adminAccessKey=$1
adminSecretAccessKey=$2
aws configure set aws_access_key_id $adminAccessKey
aws configure set aws_secret_access_key $adminSecretAccessKey
aws configure set default.region us-east-1
