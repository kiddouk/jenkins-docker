#!/bin/sh

PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin

AWS_REGION=$1
BLOCK_STORAGE_ID=$2
BUCKET=$3

apt-get install python-setuptools
easy_install pip
pip install awscli
aws configure set region $AWS_REGION
aws configure set output json
apt-get install docker.io
apt-get install curl
instance_id=`curl http://169.254.169.254/latest/meta-data/instance-id`
aws ec2 attach-volume --volume-id $BLOCK_STORAGE_ID --instance-id $instance_id --device /dev/xvdh
sleep 5
mkdir -p /mnt/jenkins_data
blkid -o list | grep xvdh
if [ $? -eq 1 ]; then
    mkfs -t ext4 /dev/xvdh
fi
mount /dev/xvdh /mnt/jenkins_data
aws s3 cp s3://$BUCKET/hub.dockerconfig .dockerconfig
docker pull kiddouk/jenkins
docker run -p 8080:8080 -v /mnt/jenkins_data:/var/jenkins_home kiddouk/jenkins
