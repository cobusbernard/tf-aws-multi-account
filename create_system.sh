#!/bin/bash
set -e

source config.env

SYSTEM_TYPE=$1
SYSTEM=$2

function usage_msg() {
  echo "The command should be used like this: ./create_system.sh <system_type> <system_name>"
  echo "Type may be 'master' or 'environment'"
}

# Input validation
if [ "$SYSTEM_TYPE" != master ] \
     && [ "$SYSTEM_TYPE" != environment ]; then
   usage_msg
   exit 1
fi

if [ "$SYSTEM_TYPE" == master ]; then
  ENVIRONMENTS=("master")
fi

if [ -z $TERRAFORM_REMOTE_BUCKET ]; then
  echo "No Terraform remote state bucket specified, please set TERRAFORM_REMOTE_BUCKET value. Please set it in 'config.env'."
  usage_msg
  exit 1
fi

if [ -z $PROFILE_PREFIX ]; then
  echo "No PROFILE_PREFIX has been set. This is used to specify the AWS profiles to use in the form 'PROFILE_PREFIX-ENVIRONMENT'. Please set it in 'config.env'"
  usage_msg
  exit 1
fi

if [ -z $AWS_REGION ]; then
  echo "No AWS_REGION has been set, please set one in 'config.env'."
  usage_msg
  exit 1
fi

if [ -z $ENVIRONMENTS ]; then
  echo "No ENVIRONMENTS array has been set, please set one with at least 1 value in 'config.env'."
  usage_msg
  exit 1
fi

if [ -z $SYSTEM ]; then
  echo "No system name specified, please give it a name of some kind, i.e. my-api, external-system, etc."
  usage_msg
  exit 1
fi

if [ -z $SYSTEM_TYPE ]; then
  echo "No system name specified, please give it a name of some kind, i.e. my-api, external-system, etc."
  usage_msg
  exit 1
fi

# Create the system directory if it doesn't exist.
mkdir -p $SYSTEM
cd $SYSTEM

# Symlink the bash util scripts from the base directory.
declare -a symlinks=("apply.sh" "plan.sh" "destroy.sh" "common.tf")

for symlink in "${symlinks[@]}"
do
  if ! [ -h "$symlink" ]; then
    ln -s ../$symlink ./
  fi
done

# Each system has specific variables for it.
touch variables.tf

# Ensure we start with a clean terraform current state for an environment.
# This will not nuke existing configs as they live in _$env/terraform.tfstate.
rm -rf .terraform
mkdir -p .terraform

for env in "${ENVIRONMENTS[@]}"
do
    echo "Creating directories & remote config for: $env"

    if [ ! -d "_$env" ]; then
      echo "Directory doesn't exist, creating _$env"
      mkdir -p _$env
    fi

    if [ ! -f _$env/terraform.tfstate ]; then
      echo "Setting up Terraform remote state for $env in S3://$TERRAFORM_REMOTE_BUCKET/$env/$SYSTEM/terraform.tfstate"
      terraform remote config \
        -backend=s3 \
        -backend-config="profile=$PROFILE_PREFIX-$env" \
        -backend-config="bucket=$TERRAFORM_REMOTE_BUCKET" \
        -backend-config="key=$env/$SYSTEM/terraform.tfstate" \
        -backend-config="region=$AWS_REGION"

      mv .terraform/terraform.tfstate _$env/terraform.tfstate
      touch _$env/environment.tfvars
    fi

    echo "Creating common environment variable file for $env"
    if [ ! -f env.$env.tfvars ]; then
      echo "aws_profile = \"$PROFILE_PREFIX\"" >> ../env.$env.tfvars
      echo "aws_account_id = \"aws_account_id\"" >> ../env.$env.tfvars
      echo "aws_region = \"aws_region\"" >> ../env.$env.tfvars
    fi
done
