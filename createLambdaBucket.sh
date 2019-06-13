#!/bin/bash
S3_BUCKETNAME=$1
if aws s3 ls "s3://$S3_BUCKETNAME" 2>&1 | grep -q 'An error occurred'
then
    aws s3api create-bucket --bucket $S3_BUCKETNAME --grant-full-control
else
    echo "Bucket already exists"
fi
