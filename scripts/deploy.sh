#!/bin/bash

set -e  # Exit on error

STACK_NAME="vpc-stack"
REGION="eu-west-2"  # Change to your AWS region

echo "🚀 Deploying VPC Stack..."

# aws cloudformation create-stack --stack-name $STACK_NAME \  first time for creating stack
aws cloudformation update-stack --stack-name $STACK_NAME \
  --template-body file://../templates/vpc.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --region $REGION

echo "⏳ Waiting for VPC Stack to complete..."
aws cloudformation wait stack-create-complete --stack-name $STACK_NAME --region $REGION
echo "✅ VPC Stack updated successfully!"

