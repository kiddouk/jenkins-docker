#!/bin/sh

PATH=/bin:/usr/bin:/usr/local/bin

AWS_REGION=$1
BLOCK_STORAGE_ID=$2
BUCKET=$3

easy_install pip
pip install awscli
aws configure set region $AWS_REGION
aws configure set output json
apt-get install curl
instance_id=`curl http://169.254.169.254/latest/meta-data/instance-id`
aws ec2 attach-volume --volume-id $BLOCK_STORAGE_ID --instance-id $instance_id --device /dev/xvdh
mkdir -p /mnt/jenkins_data
mount /dev/xvdh /mnt/jenkins_data
aws s3 cp s3://$BUCKET/.dockerconfig .
docker pull kiddouk/jenkins
docker run -p 8080:8080 -v /mnt/jenkins_data:/var/jenkins_home kiddouk/jenkins
