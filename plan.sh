#!/bin/bash
set -e

ENVIRONMENT=$1

DIR_ABS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SYSTEM=$(basename $DIR_ABS)

if [ -z $ENVIRONMENT ]; then
  echo "No ENVIRONMENT set. Please use 'development', 'staging', 'testing' or 'production'"
  exit 1
fi

if [ "$ENVIRONMENT" != development ] \
   && [ "$ENVIRONMENT" != production ]; then
     echo "Incorrect value for environment. Please use 'development', 'staging', 'testing' or 'production'"
     exit 1
fi

if ! [ -L "common.tf" ]; then
  echo "Missing common.tf symlink, creating..."
  ln -s ../common.tf common.tf
  echo "Symlink to common.tf created."
fi

echo "Preparing to apply:"
echo "==================="
echo "System: ${SYSTEM}"
echo "Environment: _$ENVIRONMENT"

rm -rf .terraform/terraform.tfstate
mkdir -p .terraform
cp _$ENVIRONMENT/terraform.tfstate ./.terraform/

terraform get

terraform plan \
  -var "environment=$ENVIRONMENT" \
  -var-file="../env.$ENVIRONMENT.tfvars" \
  -var-file=_$ENVIRONMENT/environment.tfvars \
  -out=_$ENVIRONMENT/proposed.plan
