## Remote Backends

It enables storage of terraform state in a remote, location to enable secure collaboration.

### AWS S3 + DynamoDb
Steps to initialize backin AWS and managed it with Terraform.
1. Use config from `./aws`. Make sure to `init`, `plan`, and `apply` to provision s3 bucket and dynamoDb table with local state.
2. 