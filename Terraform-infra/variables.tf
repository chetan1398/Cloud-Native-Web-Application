# AWS Configuration
variable "region" {
  description = "AWS region"
  type        = string
}

variable "profile" {
  description = "Used to represent the environment"
  type        = string
}

# VPC and Networking
variable "vpc_name" {
  description = "VPC name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zone_1" {
  description = "Availability zone 1"
  type        = string
}

variable "availability_zone_2" {
  description = "Availability zone 2"
  type        = string
}

variable "availability_zone_3" {
  description = "Availability zone 3"
  type        = string
}

# Public and Private Subnet CIDRs
variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
}

variable "public_subnet_3_cidr" {
  description = "CIDR block for public subnet 3"
  type        = string
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for private subnet 1"
  type        = string
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for private subnet 2"
  type        = string
}

variable "private_subnet_3_cidr" {
  description = "CIDR block for private subnet 3"
  type        = string
}

# EC2 and Application Configuration
variable "custom_ami" {
  description = "Custom AMI for EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Type of the instance"
  type        = string
}

variable "key_name" {
  description = "Name of the key pair for EC2 access"
  type        = string
}

variable "application_port" {
  description = "Port on which the application runs"
  type        = number
}

# Security Group Configuration
variable "ingress_ssh_port" {
  description = "Port for SSH"
  type        = number
}

variable "ingress_eighty_port" {
  description = "Port for HTTP (80)"
  type        = number
}

variable "ingress_443_port" {
  description = "Port for HTTPS (443)"
  type        = number
}

variable "protocol" {
  description = "Protocol for ingress and egress"
  type        = string
}

variable "cidr_sg" {
  description = "CIDR for security group"
  type        = string
}

variable "egress_port" {
  description = "Port for egress"
  type        = number
}

variable "egress_protocol" {
  description = "Egress protocol"
  type        = string
}

# S3 Configuration
variable "bucket_name" {
  description = "Name of the S3 bucket to store application data"
  type        = string
}


# Database Parameter Group Family
variable "db_family" {
  description = "Database family for RDS (e.g., postgres13)"
  type        = string
}

# Database Engine Version
variable "db_engine_version" {
  description = "RDS database engine version (e.g., 13.11 for PostgreSQL)"
  type        = string
}


# IAM Configuration
variable "iam_role_name" {
  description = "Name for the IAM role attached to EC2"
  type        = string
}

variable "keyID" {
  description = "Access Key ID"
  type        = string
}

variable "key" {
  description = "Access Key Secret"
  type        = string
}

# EC2 Instance Volume Configuration
variable "volume_size" {
  description = "Size of the EC2 instance volume"
  type        = number
}

variable "volume_type" {
  description = "The type of volume for the EC2 instance"
  type        = string
}

# Auto Scaling Group Configuration
variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
}



variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
}

variable "desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
}

variable "health_check_grace_period" {
  description = "Grace period for health checks in the Auto Scaling Group"
  type        = number
}

# Auto Scaling Policies Configuration
variable "scale_up_adjustment" {
  description = "Number of instances to add when scaling up"
  type        = number
}

variable "scale_down_adjustment" {
  description = "Number of instances to remove when scaling down"
  type        = number
}

variable "scale_up_cooldown" {
  description = "Cooldown period for scaling up"
  type        = number
}

variable "scale_down_cooldown" {
  description = "Cooldown period for scaling down"
  type        = number
}

# Scaling CPU Thresholds
variable "scale_up_cpu_threshold" {
  description = "CPU threshold for scaling up"
  type        = number
}

variable "scale_down_cpu_threshold" {
  description = "CPU threshold for scaling down"
  type        = number
}

# Database (RDS) Configuration
variable "db_engine" {
  description = "Database engine"
  type        = string
}

variable "db_port" {
  description = "Database port"
  type        = number
}

variable "engine_version" {
  description = "RDS engine version"
  type        = string
}

variable "db_parameter_group_family" {
  description = "Parameter group family for RDS (e.g., postgres13)"
  type        = string
}

variable "db_name" {
  description = "RDS database name"
  type        = string
}

variable "username" {
  description = "RDS username"
  type        = string
}

variable "db_password" {
  description = "The master password for the database"
  type        = string
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "allocated_storage" {
  description = "RDS allocated storage size in GB"
  type        = number
}

# RDS Backup Configuration
variable "backup_retention_period" {
  description = "The number of days to retain backups for RDS"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "The preferred backup window for RDS"
  type        = string
  default     = "02:00-03:00"
}

# RDS Multi-AZ Deployment
variable "multi_az" {
  description = "Enable multi-AZ deployment for RDS"
  type        = bool
  default     = false
}


# Route53 Configuration
variable "route53_zone_id" {
  description = "Route 53 hosted zone ID"
  type        = string
}

variable "domain_name" {
  description = "Domain name for Route 53 record"
  type        = string
}


variable "sns_topic_name" {
  description = "Name of the SNS topic for email verification"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}


variable "sendgrid_api_key" {
  description = "API key for SendGrid"
  type        = string
}

variable "ses_from_email" {
  description = "The sender email address"
  type        = string
}
