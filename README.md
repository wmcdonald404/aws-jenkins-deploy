# leeroy-deploy
Boostrap an environment, deploy resources via paramaterised, versioned Jenkins pipeline.

## Let's mirror some upstream AW

## First create the development VPC

We'll use local state, create the VPC then switch to remote state.

1. Define some environment variables

Linux:
```bash
AWS_ACCOUNT=$(aws sts get-caller-identity | jq -r .Account)
AWS_REGION=eu-west-1
TF_VAR_aws_target_account_id=$AWS_ACCOUNT
```

Powershell:
```pwsh
$AWS_ACCOUNT=(aws sts get-caller-identity | jq -r .Account)
$AWS_REGION="eu-west-1"
$Env:TF_VAR_aws_target_account_id=$AWS_ACCOUNT
```

2. Check the variables

```bash
echo -e "AWS_ACCOUNT: $AWS_ACCOUNT\nAWS_REGION: $AWS_REGION\nTF_VAR_aws_target_account_id: $TF_VAR_aws_target_account_id\n"
```

```pwsh
Write-Output  "AWS_ACCOUNT: $AWS_ACCOUNT`nAWS_REGION: $AWS_REGION`nTF_VAR_aws_target_account_id: $TF_VAR_aws_target_account_id"
```

5. Initialise the Terraform backend

```
PS> terraform init
```

6. Run a Terraform plan to validate what it would do

```
PS> terraform plan -var-file="sample.tfvars" -auto-approve
```

7. Let's go....

```
wmcdonald@fedora tf-build ±|main ✗|→ terraform apply -var-file="sample.tfvars" -auto-approve
```
