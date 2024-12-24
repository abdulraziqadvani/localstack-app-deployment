#!/bin/sh
echo "Initializing localstack services"

# Install jq for JSON parsing
apt install jq -y

# Create a key pair
awslocal ec2 create-key-pair \
    --key-name my-key \
    --query 'KeyMaterial' \
    --output text | tee key.pem
chmod 400 key.pem

# Authorize ingress on port 4200
awslocal ec2 authorize-security-group-ingress \
    --group-id default \
    --protocol tcp \
    --port 4200 \
    --cidr 0.0.0.0/0

# Retrieve security group ID
sg_id=$(awslocal ec2 describe-security-groups | jq -r '.SecurityGroups[0].GroupId')
echo $sg_id

# Run an EC2 instance
awslocal ec2 run-instances \
  --image-id ami-df5de72bdb3b \
  --count 1 \
  --instance-type t3.nano \
  --key-name my-key \
  --security-group-ids $sg_id \
  --user-data file:///opt/scripts/ec2_script.sh
