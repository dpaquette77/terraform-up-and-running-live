provider "aws" {
    region = "us-east-2"
}

terraform {
    backend "s3" {
        bucket = "dpaquette-terraform-up-and-running-state"
        key = "stage/services/webserver-cluster/terraform.tfstate"
        region = "us-east-2"
        
        dynamodb_table = "terraform-up-and-running-locks"
        encrypt = true
    }
}

module "webserver-cluster" {
    source = "github.com/dpaquette77/terraform-up-and-running-modules//services/webserver-cluster?ref=v0.0.2"
   
    cluster_name = "webservers-stage"
    db_remote_state_bucket = "dpaquette-terraform-up-and-running-state"
    db_remote_state_key = "stage/services/data-stores/mysql/terraform.tfstate"
    instance_type = "t2.micro"
    max_size = 3
    min_size = 2

    asg_custom_tags = {
        Owner = "team-foo"
        DeployedBy = "terraform"
    }
}