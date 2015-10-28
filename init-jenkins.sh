#!/bin/sh

PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin

AWS_REGION=$1
BLOCK_STORAGE_ID=$2
BUCKET=$3

apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-engine curl python-setuptools 
easy_install pip
pip install awscli
pip install requests
pip install boto
aws configure set region $AWS_REGION
aws configure set output json
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
mkdir .docker
echo "* * * * */15 root /root/jenkins-docker/jenkins-activity-check.py $AWS_REGION" > /etc/cron.d/jenkins-activity-check
aws s3 cp s3://$BUCKET/config.json .docker/config.json
docker pull kiddouk/jenkins:latest
docker run -d -p 80:8080 -v /mnt/jenkins_data:/var/jenkins_home kiddouk/jenkins
