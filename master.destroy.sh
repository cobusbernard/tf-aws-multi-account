#!/bin/bash
set -e

ENVIRONMENT=$1

DIR_ABS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SYSTEM=$(basename $DIR_ABS)

if [ -z $ENVIRONMENT ]; then
  echo "No environment set. Please use 'master'."
  exit 1
fi

if [ "$ENVIRONMENT" != master ]; then
     echo "Incorrect value for environment. Please use 'master'."
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
rm -rf .terraform/terraform.tfstate.backup
mkdir -p .terraform
cp _$ENVIRONMENT/terraform.tfstate ./.terraform/

terraform get

terraform destroy \
  -var "environment=$ENVIRONMENT" \
  -var-file=_$ENVIRONMENT/environment.tfvars
