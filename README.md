# leeroy-deploy
Boostrap an environment, deploy resources via paramaterised, versioned Jenkins pipeline.

## Overview
This repository illustrates one potential directory layout that could be used to manage resources deployed into multiple AWS member accounts. The intention is to have a local set of [central Terraform modules](<https://github.com/terraform-aws-modules>), then per-environment configuration diverging from the baseline only where absolutely necessary. 

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

Let's mirror some upstream AWS Terraform modules.

| Terraform Module   | Purpose               | URL        |
| ---                | ---                   | ---         |
| [terraform-aws-vpc](<https://github.com/terraform-aws-modules/terraform-aws-vpc>) | VPC creation | [https://github.com/terraform-aws-modules/terraform-aws-vpc](<https://github.com/terraform-aws-modules/terraform-aws-vpc>) |
| [terraform-aws-s3-bucket](<https://github.com/terraform-aws-modules/terraform-aws-s3-bucket>)              | S3 buckets | [https://github.com/terraform-aws-modules/terraform-aws-s3-bucket](<https://github.com/terraform-aws-modules/terraform-aws-s3-bucket>) |
| [terraform-aws-key-pair](<https://github.com/terraform-aws-modules/terraform-aws-key-pair>) | Managing SSH key pairs  | [https://github.com/terraform-aws-modules/terraform-aws-key-pair](<https://github.com/terraform-aws-modules/terraform-aws-key-pair>) |
| [terraform-aws-ec2-instance](<https://github.com/terraform-aws-modules/terraform-aws-ec2-instance>)| Creating EC2 instances| [https://github.com/terraform-aws-modules/terraform-aws-ec2-instance](<https://github.com/terraform-aws-modules/terraform-aws-ec2-instance>)

If we have an empty module tree we can loop over each repo and pull it down as follows:

```
MODULE_DIR=/workspaces/leeroy/tf/modules/
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
$ git clone https://github.com/terraform-aws-modules/terraform-aws-vpc /workspaces/leeroy/tf/modules/terraform-aws-vpc
$ rm -rf $_/.git $_/.github
```

2. Clone the AWS S3 bucket module and clear its upstream Git and Github history.
```bash
git clone https://github.com/terraform-aws-modules/terraform-aws-s3-bucket /workspaces/leeroy/tf/modules/terraform-aws-s3-bucket
rm -rf $_/.git $_/.github
```

3. Clone the AWS Key Pair module
```bash
git clone https://github.com/terraform-aws-modules/terraform-aws-key-pair /workspaces/leeroy/tf/modules/terraform-aws-key-pair
rm -rf $_/.git $_/.github
```

4. Clone the AWS EC2 instance module and clear its upstream Git and Github history.
```bash
git clone https://github.com/terraform-aws-modules/terraform-aws-ec2-instance /workspaces/leeroy/tf/modules/terraform-aws-ec2-instance
rm -rf $_/.git $_/.github
```

## First create the development VPC

We'll use local state, create the VPC then switch to remote state.

1. Define some environment variables

Linux:
```bash
AWS_ACCOUNT=$(aws sts get-caller-identity | jq -r .Account)
AWS_REGION=eu-west-1
export TF_VAR_aws_region=$AWS_REGION
export TF_VAR_aws_account=$AWS_ACCOUNT
```

Powershell:
```pwsh
$AWS_ACCOUNT=(aws sts get-caller-identity | jq -r .Account)
$AWS_REGION="eu-west-1"
$Env:TF_VAR_aws_region=$AWS_REGION
$Env:TF_VAR_aws_account=$AWS_ACCOUNT
```

2. Check the variables

```bash
echo -e "AWS_ACCOUNT: $AWS_ACCOUNT\nAWS_REGION: $AWS_REGION\nTF_VAR_aws_account: $TF_VAR_aws_account\nTF_VAR_aws_region: $TF_VAR_aws_region\n"
```

```pwsh
Write-Output "AWS_ACCOUNT: $AWS_ACCOUNT`nAWS_REGION: $AWS_REGION`nTF_VAR_aws_account: $TF_VAR_aws_account`nTF_VAR_aws_region: $TF_VAR_aws_region"
```

3. Initialise the Terraform backend

```bash
$ cd tf/env/sharedsvc/vpc/
$ terraform init
```

4. Run a Terraform plan to validate what it would do

```bash
$ terraform plan
```

5. Run the Terraform apply to create the shared service VPC

```bash
$ terraform apply -auto-approve
```


# References

- [https://renatogolia.com/2020/10/12/working-with-aws-in-devcontainers/](<https://renatogolia.com/2020/10/12/working-with-aws-in-devcontainers/>)
- [https://happihacking.com/blog/posts/2024/dev-containers-uids/](<https://happihacking.com/blog/posts/2024/dev-containers-uids/>)
- [https://dev.to/graezykev/dev-containers-part-2-image-features-workspace-environment-variables-375o](<https://dev.to/graezykev/dev-containers-part-2-image-features-workspace-environment-variables-375o>)