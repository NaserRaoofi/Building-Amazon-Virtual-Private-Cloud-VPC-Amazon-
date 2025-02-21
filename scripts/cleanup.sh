#!/bin/bash

STACK_NAME="vpc-stack"

echo "Starting cleanup process for CloudFormation stack: $STACK_NAME"

# Get VPC ID
VPC_ID=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].Outputs[?ExportName=='${STACK_NAME}-VpcId'].OutputValue" --output text)

if [ -z "$VPC_ID" ]; then
  echo "VPC not found. Stack may not exist. Exiting."
  exit 1
fi

echo "VPC ID: $VPC_ID"

# Find and Terminate EC2 Instances
INSTANCE_IDS=$(aws ec2 describe-instances --filters "Name=vpc-id,Values=$VPC_ID" --query "Reservations[*].Instances[*].InstanceId" --output text)
if [ "$INSTANCE_IDS" != "" ]; then
  echo "Terminating EC2 instances: $INSTANCE_IDS"
  aws ec2 terminate-instances --instance-ids $INSTANCE_IDS
  
  # Wait for EC2 instances to terminate
  for INSTANCE in $INSTANCE_IDS; do
    echo "Waiting for instance $INSTANCE to terminate..."
    aws ec2 wait instance-terminated --instance-ids $INSTANCE
  done
  echo "All EC2 instances terminated."
fi

# Find and Delete NAT Gateway
NAT_GATEWAY_IDS=$(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_ID" --query "NatGateways[*].NatGatewayId" --output text)
for NAT_ID in $NAT_GATEWAY_IDS; do
  echo "Deleting NAT Gateway: $NAT_ID"
  aws ec2 delete-nat-gateway --nat-gateway-id $NAT_ID
  aws ec2 wait nat-gateway-deleted --nat-gateway-id $NAT_ID
  echo "NAT Gateway $NAT_ID deleted."
done

# Find and Release Elastic IPs
EIP_ALLOCATION_IDS=$(aws ec2 describe-addresses --query "Addresses[*].AllocationId" --output text)
for EIP in $EIP_ALLOCATION_IDS; do
  echo "Releasing Elastic IP: $EIP"
  aws ec2 release-address --allocation-id $EIP
  echo "Elastic IP $EIP released."
done

# Detach and Delete Internet Gateway
IGW_ID=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query "InternetGateways[0].InternetGatewayId" --output text)
if [ "$IGW_ID" != "None" ]; then
  echo "Detaching and deleting Internet Gateway: $IGW_ID"
  aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
  aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID
  echo "Internet Gateway $IGW_ID deleted."
fi

# Delete RDS instance
DB_INSTANCE_ID="myDB"
echo "Deleting RDS instance: $DB_INSTANCE_ID"
aws rds delete-db-instance --db-instance-identifier $DB_INSTANCE_ID --skip-final-snapshot

# Wait for RDS instance to be deleted
echo "Waiting for RDS instance to be deleted..."
aws rds wait db-instance-deleted --db-instance-identifier $DB_INSTANCE_ID
echo "RDS instance deleted."

# Delete Subnets
SUBNET_IDS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[*].SubnetId" --output text)
for SUBNET in $SUBNET_IDS; do
  echo "Deleting Subnet: $SUBNET"
  aws ec2 delete-subnet --subnet-id $SUBNET
  echo "Subnet $SUBNET deleted."
done

# Delete Route Table
ROUTE_TABLE_ID=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" --query "RouteTables[?Associations[0].Main!=true].RouteTableId" --output text)
if [ "$ROUTE_TABLE_ID" != "None" ]; then
  echo "Deleting Route Table: $ROUTE_TABLE_ID"
  aws ec2 delete-route-table --route-table-id $ROUTE_TABLE_ID
  echo "Route Table $ROUTE_TABLE_ID deleted."
fi

# Delete Security Groups
SECURITY_GROUP_IDS=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" --query "SecurityGroups[*].GroupId" --output text)
for SG in $SECURITY_GROUP_IDS; do
  echo "Deleting Security Group: $SG"
  aws ec2 delete-security-group --group-id $SG
  echo "Security Group $SG deleted."
done

# Delete VPC
echo "Deleting VPC: $VPC_ID"
aws ec2 delete-vpc --vpc-id $VPC_ID

echo "VPC $VPC_ID deleted."

# Delete CloudFormation Stack
echo "Deleting CloudFormation Stack: $STACK_NAME"
aws cloudformation delete-stack --stack-name $STACK_NAME
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME

echo "Cleanup process completed successfully."
