# aws-jenkins-deploy
Boostrap an environment, deploy resources via paramaterised, versioned Jenkins pipeline.

## Overview
This repository illustrates one potential directory layout that could be used to manage resources deployed into multiple AWS member accounts. The intention is to have a local set of [central OpenTofu modules](<https://github.com/terraform-aws-modules>), then per-environment configuration diverging from the baseline only where absolutely necessary. 

Keeping the structure of the codebase clear, concise [and DRY](<https://en.wikipedia.org/wiki/Don%27t_repeat_yourself>).

We have 3 distinct AWS member accounts.

| AWS Member Account | Purpose               | CIDR        |
| ---                | ---                   | ---         |
| sharedsvc          | Shared services       | 10.0.0.0/16 |
| development        | Development workloads | 10.2.0.0/16 |
| production         | Production workloads  | 10.4.0.0/16 |

The structure of the codebase is shown below in a simplified form. Common configuration comes from a single set of shared modules. Environment-specific configuration deviation exists per resource per-env. 

```
.
└── tf
    ├── env
    │   ├── development
    │   │   ├── ec2
    │   │   └── vpc
    │   ├── production
    │   │   ├── ec2
    │   │   └── vpc
    │   └── sharedsvc
    │       ├── ec2
    │       └── vpc
    └── modules
        ├── terraform-aws-ec2-instance
        └── terraform-aws-vpc
```                

## Mirror upstream modules 

Let's mirror some upstream AWS OpenTofu modules.

| OpenTofu Module   | Purpose               | URL        |
| ---                | ---                   | ---         |
| [terraform-aws-vpc](<https://github.com/terraform-aws-modules/terraform-aws-vpc>) | VPC creation | [https://github.com/terraform-aws-modules/terraform-aws-vpc](<https://github.com/terraform-aws-modules/terraform-aws-vpc>) |
| [terraform-aws-s3-bucket](<https://github.com/terraform-aws-modules/terraform-aws-s3-bucket>)              | S3 buckets | [https://github.com/terraform-aws-modules/terraform-aws-s3-bucket](<https://github.com/terraform-aws-modules/terraform-aws-s3-bucket>) |
| [terraform-aws-key-pair](<https://github.com/terraform-aws-modules/terraform-aws-key-pair>) | Managing SSH key pairs  | [https://github.com/terraform-aws-modules/terraform-aws-key-pair](<https://github.com/terraform-aws-modules/terraform-aws-key-pair>) |
| [terraform-aws-ec2-instance](<https://github.com/terraform-aws-modules/terraform-aws-ec2-instance>)| Creating EC2 instances| [https://github.com/terraform-aws-modules/terraform-aws-ec2-instance](<https://github.com/terraform-aws-modules/terraform-aws-ec2-instance>)

If we have an empty module tree we can loop over each repo and pull it down as follows:

```
MODULE_DIR=/workspaces/aws-jenkins-deploy/tf/modules/
declare -a URLS=(
"https://github.com/terraform-aws-modules/terraform-aws-vpc"
"https://github.com/terraform-aws-modules/terraform-aws-s3-bucket"
"https://github.com/terraform-aws-modules/terraform-aws-key-pair"
"https://github.com/terraform-aws-modules/terraform-aws-ec2-instance")

for URL in "${URLS[@]}"
do
    git clone $URL ${MODULE_DIR}/$(basename $URL)
    rm -rf $_/.git $_/.github
done
```

If we need to do individual modules we can process each as follows:

1. Clone the AWS VPC module and clear its upstream Git and Github history.
```bash
$ git clone https://github.com/terraform-aws-modules/terraform-aws-vpc /workspaces/aws-jenkins-deploy/tf/modules/terraform-aws-vpc
$ rm -rf $_/.git $_/.github
```

2. Clone the AWS S3 bucket module and clear its upstream Git and Github history.
```bash
git clone https://github.com/terraform-aws-modules/terraform-aws-s3-bucket /workspaces/aws-jenkins-deploy/tf/modules/terraform-aws-s3-bucket
rm -rf $_/.git $_/.github
```

3. Clone the AWS Key Pair module
```bash
git clone https://github.com/terraform-aws-modules/terraform-aws-key-pair /workspaces/aws-jenkins-deploy/tf/modules/terraform-aws-key-pair
rm -rf $_/.git $_/.github
```

4. Clone the AWS EC2 instance module and clear its upstream Git and Github history.
```bash
git clone https://github.com/terraform-aws-modules/terraform-aws-ec2-instance /workspaces/aws-jenkins-deploy/tf/modules/terraform-aws-ec2-instance
rm -rf $_/.git $_/.github
```

## First create the sharedsvc VPC

We'll use local state, create the VPC, an S3 bucket, then switch to remote state.

1. Set your AWS_PROFILE and check token validity

```bash
$ export AWS_PROFILE=awsprofile.sharedsvc
$ aws sts get-caller-identity
```

> *Note:* if `aws sts get-caller-identity` does not return valid JSON data for the expected account, run `aws sso login --no-browser`.

2. Define some environment variables

Linux:
```bash
AWS_ACCOUNT=$(aws sts get-caller-identity | jq -r .Account)
AWS_ENV=sharedsvc
AWS_REGION=eu-west-1
export TF_VAR_aws_account=$AWS_ACCOUNT
export TF_VAR_aws_env=$AWS_ENV
export TF_VAR_aws_region=$AWS_REGION
```

3. Check the variables

```bash
echo -e "AWS_ACCOUNT: $AWS_ACCOUNT\nAWS_REGION: $AWS_REGION\nTF_VAR_aws_account: $TF_VAR_aws_account\nTF_VAR_aws_region: $TF_VAR_aws_region\n"
```

4. Initialise the OpenTofu backend

```bash
$ cd /workspace/aws-jenkins-deploy/tf/env/sharedsvc/
$ tofu init
```

5. Run a OpenTofu plan to validate what it would do

```bash
$ tofu plan
```

6. Run the OpenTofu apply to create the shared service VPC and its shared state bucket.

```bash
$ tofu apply -auto-approve
```

7. Migrate to shared state, first uncomment the following in `providers.tf`

```hcl
  backend "s3" {
    bucket       = "${var.aws_account}-${var.aws_env}-s3-state-bucket"
    encrypt      = true
    key          = "${var.aws_account}-${var.aws_env}-s3-state-key"
    region       = var.aws_region
    # This enables native S3 state locking
    use_lockfile = true
  }
```

8. Migrate from local state to S3 shared state.

```bash
$ tofu init -migrate-state -force-copy
```

At this point we can remove the terraform.tfstate, terraform.tfstate.backup, and .terraform.lock.hcl from the local file system. 

## Next create the development VPC

Repeat the previous steps, switching the paths and variables for the development member account.

1. Set your AWS_PROFILE and check token validity

```bash
$ export AWS_PROFILE=awsprofile.development
$ aws sts get-caller-identity
```

2. Define some environment variables

Linux:
```bash
AWS_ACCOUNT=$(aws sts get-caller-identity | jq -r .Account)
AWS_ENV=development
AWS_REGION=eu-west-1
export TF_VAR_aws_account=$AWS_ACCOUNT
export TF_VAR_aws_env=$AWS_ENV
export TF_VAR_aws_region=$AWS_REGION
```

3. Initialise the OpenTofu backend

```bash
$ cd /workspace/aws-jenkins-deploy/tf/env/development/vpc/
$ tofu init
```


# Powershell Environment

Powershell:
```pwsh
$AWS_ACCOUNT=(aws sts get-caller-identity | jq -r .Account)
$AWS_ENV="sharedsvc"
$AWS_REGION="eu-west-1"
$Env:TF_VAR_aws_account=$AWS_ACCOUNT
$Env:TF_VAR_aws_env=$AWS_ENV
$Env:TF_VAR_aws_region=$AWS_REGION
```

```pwsh
Write-Output "AWS_ACCOUNT: $AWS_ACCOUNT`nAWS_ENV: $AWS_ENV`nAWS_REGION: $AWS_REGION`nTF_VAR_aws_account: $TF_VAR_aws_account`nTF_VAR_aws_env: $TF_VAR_aws_env`nTF_VAR_aws_region: $TF_VAR_aws_region"
```

# References
- [https://renatogolia.com/2020/10/12/working-with-aws-in-devcontainers/](<https://renatogolia.com/2020/10/12/working-with-aws-in-devcontainers/>)
- [https://happihacking.com/blog/posts/2024/dev-containers-uids/](<https://happihacking.com/blog/posts/2024/dev-containers-uids/>)
- [https://dev.to/graezykev/dev-containers-part-2-image-features-workspace-environment-variables-375o](<https://dev.to/graezykev/dev-containers-part-2-image-features-workspace-environment-variables-375o>)
- [https://terrateam.io/blog/migrating-terraform-state-between-backends/](<https://terrateam.io/blog/migrating-terraform-state-between-backends/>)
