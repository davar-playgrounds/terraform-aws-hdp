# terraform-aws-hdp
Launch instances on AWS

Launch a VPC with 2 subnets:
- public subnet: KNOX instance
- private subnet: Cluster instances

Use a remote tfstate for each section
terraform remote config \                                                                                                [13:35:32]
    -backend=s3 \
    -backend-config="bucket=<bucket-name>" \
	-backend-config="key=<env>/<section>/terraform.tfstate" \
    -backend-config="region=eu-west-2" \
    -backend-config="encrypt=true"

Split the env in three part:
 - VPC + subnets
 - Edge node
 - Cluster node

 Need to go in each individual folder to start / stop env - Always start VPC first ( stop last ) 

 Using a global variable config file.