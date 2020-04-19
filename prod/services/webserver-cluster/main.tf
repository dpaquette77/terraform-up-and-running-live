provider "aws" {
    region = "us-east-2"
}

terraform {
    backend "s3" {
        bucket = "dpaquette-terraform-up-and-running-state"
        key = "prod/services/webserver-cluster/terraform.tfstate"
        region = "us-east-2"
        
        dynamodb_table = "terraform-up-and-running-locks"
        encrypt = true
    }
}

module "webserver-cluster" {
    source = "github.com/dpaquette77/terraform-up-and-running-modules//services/webserver-cluster?ref=v0.0.9"
   
    cluster_name = "webservers-prod"
    db_remote_state_bucket = "dpaquette-terraform-up-and-running-state"
    db_remote_state_key = "prod/services/data-stores/mysql/terraform.tfstate"
    instance_type = "t2.micro"
    webserver_ami = "ami-0c55b159cbfafe1f0"
    max_size = 3
    min_size = 2
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
    scheduled_action_name = "scale_out_during_business_hours"
    min_size = 1
    max_size = 3
    desired_capacity = 1
    recurrence = "0 9 * * *"
    autoscaling_group_name = module.webserver-cluster.asg_name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
    scheduled_action_name = "scale_in_at_night"
    min_size = 1
    max_size = 2
    desired_capacity = 1
    recurrence = "0 17 * * *"
    autoscaling_group_name = module.webserver-cluster.asg_name
}