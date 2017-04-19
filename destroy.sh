#!/bin/bash
set -e

environment=$1

ENVIRONMENT=$1

DIR_ABS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SYSTEM=$(basename $DIR_ABS)

if [ -z $ENVIRONMENT ]; then
  echo "No environment set. Please use 'development', 'stagaing', 'testing' or 'production'"
  exit 1
fi

if [ "$ENVIRONMENT" != development ] \
   && [ "$ENVIRONMENT" != testing ] \
   && [ "$ENVIRONMENT" != staging ] \
   && [ "$ENVIRONMENT" != production ]; then
     echo "Incorrect value for environment. Please use 'development', 'stagaing', 'testing' or 'production'"
     exit 1
fi

echo "Preparing to apply:"
echo "==================="
echo "System: ${SYSTEM}"
echo "Environment: _$ENVIRONMENT"

rm -rf .terraform/terraform.tfstate
mkdir -p .terraform
cp _$ENVIRONMENT/terraform.tfstate ./.terraform/

terraform destroy \
  -var "environment=$environment" \
  -var-file="../env.$ENVIRONMENT.tfvars" \
  -var-file=_$environment/environment.tfvars
