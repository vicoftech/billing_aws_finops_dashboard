#!/bin/bash

# AWS Credentials Configuration Helper
# This script helps configure AWS credentials for the Cost Analytics project

set -e

ENVIRONMENT=$1
CONFIGURE_SSO=$2
CHECK_CREDENTIALS=$3

if [ -z "$ENVIRONMENT" ]; then
    echo "Usage: $0 <environment> [sso] [check]"
    echo "Environments: dev, staging, prod"
    echo "Options:"
    echo "  sso   - Configure AWS SSO"
    echo "  check - Check existing credentials"
    exit 1
fi

# Map environment to profile name
case $ENVIRONMENT in
    dev)
        PROFILE_NAME="bsj_dev"
        ;;
    staging)
        PROFILE_NAME="bsj_test"
        ;;
    prod)
        PROFILE_NAME="bsj_prod"
        ;;
    *)
        echo "Invalid environment. Must be: dev, staging, prod"
        exit 1
        ;;
esac

echo "=== AWS Credentials Configuration for $ENVIRONMENT Environment ==="
echo "Profile: $PROFILE_NAME"

# Check credentials
if [ "$CHECK_CREDENTIALS" = "check" ]; then
    echo -e "\n🔍 Checking current AWS credentials..."

    # Check if profile exists
    if aws configure list-profiles | grep -q "^$PROFILE_NAME$"; then
        echo "✅ Profile '$PROFILE_NAME' exists"

        # Test credentials
        if aws sts get-caller-identity --profile $PROFILE_NAME >/dev/null 2>&1; then
            IDENTITY=$(aws sts get-caller-identity --profile $PROFILE_NAME --output json)
            ACCOUNT=$(echo $IDENTITY | jq -r '.Account')
            USER_ID=$(echo $IDENTITY | jq -r '.UserId')
            ARN=$(echo $IDENTITY | jq -r '.Arn')

            echo "✅ Credentials are valid"
            echo "   Account: $ACCOUNT"
            echo "   User: $USER_ID"
            echo "   ARN: $ARN"
        else
            echo "❌ Credentials are invalid or expired"
            echo "   Run: $0 $ENVIRONMENT check"
        fi
    else
        echo "❌ Profile '$PROFILE_NAME' does not exist"
    fi
    exit 0
fi

# SSO Configuration
if [ "$CONFIGURE_SSO" = "sso" ]; then
    echo -e "\n🔐 Configuring AWS SSO..."

    # Check if AWS CLI SSO is configured
    if aws configure sso list-sessions >/dev/null 2>&1; then
        echo "SSO sessions found. Use one of these:"
        aws configure sso list-sessions
    else
        echo "No SSO sessions found. Please configure SSO first:"
        echo "aws configure sso"
        exit 1
    fi

    echo -e "\nRun these commands to configure SSO for $PROFILE_NAME profile:"
    echo "aws configure sso --profile $PROFILE_NAME"
    echo "aws sso login --profile $PROFILE_NAME"
    exit 0
fi

# Manual credential configuration
echo -e "\n🔑 Manual AWS Credentials Configuration"
echo "You need to provide AWS Access Key ID and Secret Access Key."
echo "Get these from: https://console.aws.amazon.com/iam/ -> Users -> Security credentials"

echo -e "\nDo you want to configure AWS credentials now? (yes/no)"
read -r configure

if [ "$configure" != "yes" ]; then
    echo "Configuration cancelled."
    exit 0
fi

echo -e "\n⚠️  IMPORTANT SECURITY NOTES:"
echo "• Never share your AWS credentials"
echo "• Use IAM users with minimal required permissions"
echo "• Consider using AWS SSO instead for better security"
echo "• Rotate access keys regularly"

echo -e "\nEnter AWS Access Key ID:"
read -r access_key

echo "Enter AWS Secret Access Key:"
read -rs secret_key
echo

echo "Enter AWS Region (default: us-east-1):"
read -r region
if [ -z "$region" ]; then
    region="us-east-1"
fi

# Configure the profile
echo -e "\n🔧 Configuring AWS profile: $PROFILE_NAME"

aws configure set aws_access_key_id "$access_key" --profile "$PROFILE_NAME"
aws configure set aws_secret_access_key "$secret_key" --profile "$PROFILE_NAME"
aws configure set region "$region" --profile "$PROFILE_NAME"

echo "✅ AWS profile '$PROFILE_NAME' configured successfully!"

# Test the credentials
echo -e "\n🔍 Testing credentials..."
if aws sts get-caller-identity --profile "$PROFILE_NAME" >/dev/null 2>&1; then
    IDENTITY=$(aws sts get-caller-identity --profile "$PROFILE_NAME" --output json)
    ACCOUNT=$(echo $IDENTITY | jq -r '.Account')
    ARN=$(echo $IDENTITY | jq -r '.Arn')

    echo "✅ Credentials are valid!"
    echo "   Account: $ACCOUNT"
    echo "   ARN: $ARN"

    echo -e "\n🎉 Setup complete! You can now use Terraform with this profile."
    echo "Example: ./scripts/workspace-helper.sh $ENVIRONMENT plan"
else
    echo "❌ Credential test failed"
    echo -e "\n🔧 Troubleshooting:"
    echo "1. Check that your access keys are correct"
    echo "2. Ensure your IAM user has the required permissions"
    echo "3. Verify that the access keys are not expired"
    exit 1
fi
