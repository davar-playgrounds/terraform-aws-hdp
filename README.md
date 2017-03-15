# terraform-aws-hdp
Launch instances on AWS

Launch a VPC with 2 subnets:
- public subnet: KNOX instance
- private subnet: Cluster instances

Split the env in three part:
 - VPC + subnets
 - Edge node
 - Cluster node

Need to go in each individual folder to start / stop env - Always start VPC first ( stop last ) 

Use a remote tfstate for each section, you can configure by doing the following in each section.
~~~~
terraform remote config \                                                                                                
    -backend=s3 \
    -backend-config="bucket=<bucket-name>" \
    -backend-config="key=<env>/<section>/terraform.tfstate" \
    -backend-config="region=eu-west-2" \
    -backend-config="encrypt=true"
~~~~

 Using a global variable config file.
