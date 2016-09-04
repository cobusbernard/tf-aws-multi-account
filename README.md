# tf-aws-multi-account
Used as a starting point for an AWS, multi-root account setup [read here for more](http://cobus.io/aws/2016/09/03/AWS_Multi_Account.html). There is a master account where all the users live, and environment accounts, i.e. `development`, `testing`, `production`. When dealing with master only resources, the environment is also `master`.


# Getting started
Set the appropriate values in `config.env`. The bash scripts work with the following conventions:
* Your AWS profile in `~/.aws/credentials` is in the format `<prefix>-<environment>`, i.e. `my_company-master` or `my_company-development`.
* The remote state is stored in a single bucket, with key `<system>/<environment>/` for each system / environment combination.
* The profile for each environment is used for uploading the files, so other profiles can't read them. This means that `development` can't read `production`, but they can both read from `master`, but not write.

The folder structure looks like this:

## Variables
Please set the values for `config.env`, should look something like:
~~~
TERRAFORM_REMOTE_BUCKET=my_company-terraform-state
PROFILE_PREFIX=my_company
AWS_REGION=us-west-2
ENVIRONMENTS=("development" "production")
~~~


## AWS setup
Until [this issue](https://github.com/hashicorp/terraform/issues/1275) is merged in Terraform, assuming roles for the AWS provider is not supported. Please create an admin user (and api keys) per account, and ensure you have the profile set in `~/.aws/credentials` in the following format:

~~~
[my_company-master]
aws_access_key_id=<key>
aws_secret_access_key=<secret>

[my_company-development]
aws_access_key_id=<key>
aws_secret_access_key=<secret>

[my_company-production]
aws_access_key_id=<key>
aws_secret_access_key=<secret>
~~~

You will need to create a bucket in the master account to contain the remote state with the correct permissions. Choose a bucket name, i.e. `my-terraform-state` with a policy:

~~~
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Allow_environment_to_read_master",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::<dev_aws_account_id>:root",
          "arn:aws:iam::<prod_aws_account_id>:root"
        ]
      },
      "Action": [
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:GetObjectVersion",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::my-terraform-state/master/*"
    },
    {
      "Sid": "Allow_development_to_get_environment_folder",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::<dev_aws_account_id>:root"
        ]
      },
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListBucket",
        "s3:ListBucketVersions"
      ],
      "Resource": "arn:aws:s3:::my-terraform-state"
    },
    {
      "Sid": "Allow_development_to_read_write_environment_folder",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::<dev_aws_account_id>:root"
        ]
      },
      "Action": [
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:GetObjectVersion",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::my-terraform-state/production/*"
    },
    {
      "Sid": "Allow_production_to_get_environment_folder",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::<prod_aws_account_id>:root"
        ]
      },
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListBucket",
        "s3:ListBucketVersions"
      ],
      "Resource": "arn:aws:s3:::my-terraform-state"
    },
    {
      "Sid": "Allow_production_to_read_write_environment_folder",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::<prod_aws_account_id>:root"
        ]
      },
      "Action": [
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:GetObjectVersion",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::my-terraform-state/production/*"
    }
  ]
}
~~~

This policy allows each environment's profile to read & write to that environment's state, read master's state, but not read or write to the other environments. This creates insulation between the different environments.
