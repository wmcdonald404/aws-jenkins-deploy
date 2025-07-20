# leeroy-deploy
Boostrap an environment, deploy resources via paramaterised, versioned Jenkins pipeline.

## Let's mirror some upstream AWS Terraform modules

```
$ git clone https://github.com/terraform-aws-modules/terraform-aws-vpc /workspaces/leeroy/tf/modules/terraform-aws-modules/vpc/aws
$ rm -rf $_/.git
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

```
$ cd tf/env/development/vpc/
$ terraform init
```

4. Run a Terraform plan to validate what it would do

```
PS> terraform plan
```

5. Run the Terraform apply to create the development VPC

```
$ terraform apply -auto-approve
```


# References

- [https://renatogolia.com/2020/10/12/working-with-aws-in-devcontainers/](<https://renatogolia.com/2020/10/12/working-with-aws-in-devcontainers/>)
- [https://happihacking.com/blog/posts/2024/dev-containers-uids/](<https://happihacking.com/blog/posts/2024/dev-containers-uids/>)
- [https://dev.to/graezykev/dev-containers-part-2-image-features-workspace-environment-variables-375o](<https://dev.to/graezykev/dev-containers-part-2-image-features-workspace-environment-variables-375o>)