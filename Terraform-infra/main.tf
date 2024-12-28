#######################################
# VPC & Networking Infrastructure
#######################################

# VPC Configuration
resource "aws_vpc" "vpc_network" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.vpc_name}-${random_id.vpc_suffix.hex}"
  }
}

# Generate Random ID for Unique Naming
resource "random_id" "vpc_suffix" {
  byte_length = 4
}

# Internet Gateway for VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc_network.id
  tags = {
    Name = "${var.vpc_name}-igw-${random_id.vpc_suffix.hex}"
  }
}

#######################################
# Subnet Configuration (Public & Private)
#######################################

# Public Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.vpc_network.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-public-1-${random_id.vpc_suffix.hex}"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.vpc_network.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-public-2-${random_id.vpc_suffix.hex}"
  }
}

resource "aws_subnet" "public_subnet_3" {
  vpc_id                  = aws_vpc.vpc_network.id
  cidr_block              = var.public_subnet_3_cidr
  availability_zone       = var.availability_zone_3
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-public-3-${random_id.vpc_suffix.hex}"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.vpc_network.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.availability_zone_1
  tags = {
    Name = "${var.vpc_name}-private-1-${random_id.vpc_suffix.hex}"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.vpc_network.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.availability_zone_2
  tags = {
    Name = "${var.vpc_name}-private-2-${random_id.vpc_suffix.hex}"
  }
}

resource "aws_subnet" "private_subnet_3" {
  vpc_id            = aws_vpc.vpc_network.id
  cidr_block        = var.private_subnet_3_cidr
  availability_zone = var.availability_zone_3
  tags = {
    Name = "${var.vpc_name}-private-3-${random_id.vpc_suffix.hex}"
  }
}

#######################################
# Route Tables and Associations
#######################################

# Public Route Table and Route for Internet Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc_network.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.vpc_name}-public-rt-${random_id.vpc_suffix.hex}"
  }
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc_network.id
  tags = {
    Name = "${var.vpc_name}-private-rt-${random_id.vpc_suffix.hex}"
  }
}

# Route Table Associations for Public Subnets
resource "aws_route_table_association" "public_rt_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_assoc_3" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.public_rt.id
}

# Route Table Associations for Private Subnets
resource "aws_route_table_association" "private_rt_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_assoc_3" {
  subnet_id      = aws_subnet.private_subnet_3.id
  route_table_id = aws_route_table.private_rt.id
}

#######################################
# Load Balancer Setup
#######################################


#######################################
# Load Balancer Security Group
#######################################

resource "aws_security_group" "lb_security_group" {
  name        = "${var.vpc_name}-load-balancer-sg"
  description = "Security group for the load balancer"
  vpc_id      = aws_vpc.vpc_network.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.vpc_name}-LoadBalancerSG"
  }
}

#######################################
# Application Security Group (app_sg)
#######################################

resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.vpc_network.id
  name   = "${var.vpc_name}-app-sg"

  # Allow HTTP/HTTPS traffic only from the load balancer security group
  ingress {
    from_port       = var.application_port
    to_port         = var.application_port
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_security_group.id] # Only from LB SG
  }

  # SSH access for administrative purposes
  ingress {
    from_port        = var.ingress_ssh_port
    to_port          = var.ingress_ssh_port
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # Replace with a specific IP if needed for SSH
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.vpc_name}-app-sg"
  }
}

# Create an A record pointing to the ALB
resource "aws_route53_record" "app_record" {
  zone_id = var.route53_zone_id
  name    = "${var.profile}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.app_load_balancer.dns_name
    zone_id                = aws_lb.app_load_balancer.zone_id
    evaluate_target_health = true
  }
}




#######################################
# Auto Scaling Group and Launch Template
#######################################

# Launch Template

# Launch Template with User Data Script for Auto Scaling Group
resource "aws_launch_template" "web_app_launch_template" {
  name          = "csye6225_asg_template"
  image_id      = var.custom_ami
  instance_type = var.instance_type
  key_name      = var.key_name
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }
  vpc_security_group_ids = [aws_security_group.app_sg.id]



  # User data script for configuring EC2 instance
  user_data = base64encode(<<-EOF
  #!/bin/bash
  set -e

  # Install dependencies
  sudo apt-get update -y
  sudo apt-get install -y jq awscli

  exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

  # Define paths and filenames

  src_directory="/opt/webapp/src"
  env_file="/opt/webapp/.env"
  

  # Ensure the application directory exists
  mkdir -p /opt/webapp

  # Retrieve the database credentials from Secrets Manager
  DB_SECRET=$(aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.rds_password_secret.id} --region ${var.region})
  DB_USERNAME=$(echo $DB_SECRET | jq -r '.SecretString | fromjson | .username')
  DB_PASSWORD=$(echo $DB_SECRET | jq -r '.SecretString | fromjson | .password')

  # Retrieve the database hostname
  DB_HOSTNAME=$(echo "${aws_db_instance.db_instance.endpoint}" | cut -d':' -f1)

  # Create the .env file with necessary environment variables
  cat <<EOF2 > $env_file
  DB_HOST=$DB_HOSTNAME
  DB_DATABASE=csye6225
  DB_USERNAME=$DB_USERNAME
  DB_PASSWORD=$DB_PASSWORD
  SERVER_PORT=${var.application_port}
  REGION=${var.region}
  AWS_ACCESS_KEY_ID=${var.keyID}
  AWS_SECRET_ACCESS_KEY=${var.key}
  S3_BUCKET=${aws_s3_bucket.private_bucket.bucket}
  SNS_TOPIC_ARN=${aws_sns_topic.email_verification.arn}
  EOF2

    # Copy the .env file to the src directory
    #sudo cp -f $env_file $src_directory/.env

    # Set permissions for security
    #chmod 600 $env_file

    # Restart application service
    sudo systemctl restart csye6225.service 




    # Download and install CloudWatch Agent
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb -O amazon-cloudwatch-agent.deb
    sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

    # Fetch the InstanceId for CloudWatch dimension
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

    # CloudWatch Agent configuration
    cat <<'CONFIG' > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
    {
      "agent": {
          "metrics_collection_interval": 10,
          "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
      },
      "logs": {
          "logs_collected": {
              "files": {
                  "collect_list": [
                      {
                          "file_path": "/var/log/syslog",
                          "log_group_name": "EC2AppLogs",
                          "log_stream_name": "syslog",
                          "timestamp_format": "%b %d %H:%M:%S"
                      },
                      {
                          "file_path": "/opt/webapp/logs/app.log",
                          "log_group_name": "EC2AppLogs",
                          "log_stream_name": "app_log",
                          "timestamp_format": "%Y-%m-%dT%H:%M:%S.%LZ"
                      }
                  ]
              }
          }
      },
      "metrics": {
        "append_dimensions": {
          "InstanceId": "$INSTANCE_ID"
        },
        "metrics_collected": {
          "disk": {
            "resources": ["/"],
            "measurement": ["used_percent"],
            "metrics_collection_interval": 60
          },
          "mem": {
            "measurement": ["mem_used_percent"],
            "metrics_collection_interval": 60
          }
        }
      }
    }
    CONFIG

    # Start CloudWatch Agent
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
        -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
  EOF
  )

  tags = {
    Name = "WebAppInstance"
  }
}


# Auto Scaling Group
resource "aws_autoscaling_group" "web_app_asg" {
  launch_template {
    id      = aws_launch_template.web_app_launch_template.id
    version = "$Latest"
  }

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity
  vpc_zone_identifier = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id,
    aws_subnet.public_subnet_3.id
  ]

  health_check_type         = "ELB"
  health_check_grace_period = var.health_check_grace_period
  target_group_arns         = [aws_lb_target_group.app_target_group.arn]

  tag {
    key                 = "Name"
    value               = "AutoScalingInstance"
    propagate_at_launch = true
  }
}


#######################################
# CloudWatch Metric Alarms for Auto Scaling
#######################################

# CloudWatch Metric Alarm for Scaling Up
resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "${var.vpc_name}-scale-up-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = var.scale_up_cpu_threshold # Set your CPU threshold for scaling up
  alarm_description   = "Alarm to trigger scale up when CPU exceeds threshold"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_app_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_up_policy.arn] # Connects to scale-up policy

  tags = {
    Name = "${var.vpc_name}-ScaleUpAlarm"
  }
}

# CloudWatch Metric Alarm for Scaling Down
resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "${var.vpc_name}-scale-down-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = var.scale_down_cpu_threshold # Set your CPU threshold for scaling down
  alarm_description   = "Alarm to trigger scale down when CPU is below threshold"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_app_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_down_policy.arn] # Connects to scale-down policy

  tags = {
    Name = "${var.vpc_name}-ScaleDownAlarm"
  }
}



# Auto Scaling Policy for scaling up
resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "scale-up-policy"
  scaling_adjustment     = var.scale_up_adjustment
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.scale_up_cooldown
  autoscaling_group_name = aws_autoscaling_group.web_app_asg.name
}

# Auto Scaling Policy for scaling down
resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "scale-down-policy"
  scaling_adjustment     = var.scale_down_adjustment
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.scale_down_cooldown
  autoscaling_group_name = aws_autoscaling_group.web_app_asg.name
}


# Create an Application Load Balancer
resource "aws_lb" "app_load_balancer" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_security_group.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id, aws_subnet.public_subnet_3.id]

  tags = {
    Name = "AppLoadBalancer"
  }
}

# Target Group for Load Balancer
resource "aws_lb_target_group" "app_target_group" {
  name     = "app-target-group"
  port     = var.application_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_network.id

  health_check {
    path                = "/healthz"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = "200-299"
  }

  tags = {
    Name = "AppTargetGroup"
  }
}

# Listener for Load Balancer
#resource "aws_lb_listener" "app_listener" {
#  load_balancer_arn = aws_lb.app_load_balancer.arn
#  port              = 80
#  protocol          = "HTTP"

#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.app_target_group.arn
#  }
#}



#######################################
# RDS (PostgreSQL) Configuration
#######################################

# RDS Parameter Group for PostgreSQL
resource "aws_db_parameter_group" "db_param_group" {
  name        = "${var.vpc_name}-rds1-params"
  family      = "postgres13"
  description = "Custom parameter group for ${var.db_engine}"

  parameter {
    name         = "max_connections"
    value        = "150"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "log_statement"
    value        = "all"
    apply_method = "pending-reboot"
  }

  tags = {
    Name = "${var.vpc_name}-db-param-group"
  }
}

# RDS DB Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.vpc_name}-db-subnet1-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id, aws_subnet.private_subnet_3.id]

  tags = {
    Name = "${var.vpc_name}-db-subnet1-group"
  }
}

# RDS Instance for PostgreSQL 13
resource "aws_db_instance" "db_instance" {
  identifier             = "csye6225"
  engine                 = var.db_engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  multi_az               = false
  publicly_accessible    = false
  username               = var.username
  #password               = var.db_password
  password             = random_password.rds_password.result
  parameter_group_name = aws_db_parameter_group.db_param_group.name
  db_name              = var.db_name
  port                 = var.db_port

  # Enable KMS Encryption
  kms_key_id = aws_kms_key.rds_key.arn

  storage_encrypted   = true
  skip_final_snapshot = true
  apply_immediately   = true

  tags = {
    Name = "${var.vpc_name}-rds-instance"
  }
}







#######################################
# S3 Bucket Configuration
#######################################

# S3 Bucket with UUID Naming, Lifecycle Policy, and Encryption
resource "random_uuid" "s3_bucket_name" {}

resource "aws_s3_bucket" "private_bucket" {
  bucket        = "${var.bucket_name}-${random_uuid.s3_bucket_name.result}"
  force_destroy = true

  tags = {
    Name = "My Private S3 Bucket"
  }
}


# Enable Server-Side Encryption with KMS for S3
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.private_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_key.arn
    }
  }
}


# S3 Bucket Lifecycle Policy for Transition to STANDARD_IA after 30 Days
resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  bucket = aws_s3_bucket.private_bucket.id

  rule {
    id     = "TransitionToIA"
    status = "Enabled"
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

# Enable Default Server-Side Encryption for S3 Bucket
#resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
#  bucket = aws_s3_bucket.private_bucket.id

#  rule {
#    apply_server_side_encryption_by_default {
#      sse_algorithm = "AES256"
#    }
#  }
#}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "s3_bucket_access_block" {
  bucket                  = aws_s3_bucket.private_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Policy to Deny Insecure Requests
resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.private_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "DenyPublicRead",
        Effect    = "Deny",
        Principal = "*",
        Action    = ["s3:GetObject"],
        Resource  = "${aws_s3_bucket.private_bucket.arn}/*",
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

#######################################
# Security Groups
#######################################

# Database Security Group
resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.vpc_network.id
  name   = "${var.vpc_name}-db-sg"

  # Allow traffic from both app_sg and lambda_security_group
  ingress {
    from_port = var.db_port
    to_port   = var.db_port
    protocol  = "tcp"
    security_groups = [
      aws_security_group.app_sg.id,
      aws_security_group.lambda_security_group.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.vpc_network.cidr_block]
  }

  tags = {
    Name = "${var.vpc_name}-db-sg"
  }
}

# Explicit Rule to Allow Lambda to Access RDS
#resource "aws_security_group_rule" "allow_lambda_to_rds" {
#  type                     = "ingress"
#  from_port                = var.db_port # Port 5432 for PostgreSQL
#  to_port                  = var.db_port
#  protocol                 = "tcp"
#  security_group_id        = aws_security_group.db_sg.id                 # Attach to the RDS SG
#  source_security_group_id = aws_security_group.lambda_security_group.id # Allow traffic from Lambda SG
#}


#######################################
# Lambda Security Group
#######################################

resource "aws_security_group" "lambda_security_group" {
  name        = "lambda-sg"
  description = "Security group for Lambda to access RDS and the internet"
  vpc_id      = aws_vpc.vpc_network.id

  # Outbound rule: Allow Lambda to connect to RDS
  egress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc_network.cidr_block]
  }

  # Outbound rule: Allow Lambda to access the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound rule: Allow response traffic from RDS and other VPC resources
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.vpc_network.cidr_block]
  }

  tags = {
    Name = "LambdaSecurityGroup"
  }
}


#######################################
# IAM Roles & Policies for EC2 and S3 Access
#######################################

# IAM Role for EC2 instance with CloudWatch Agent and S3 Access
resource "aws_iam_role" "ec2_role" {
  name = "EC2CloudWatchS3AccessRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy Attachment for CloudWatch Agent
resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# S3 Bucket Access Policy Document for EC2 Role
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    actions   = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.private_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.ec2_role.arn]
    }
  }

  statement {
    actions = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = [
      "${aws_s3_bucket.private_bucket.arn}",
      "${aws_s3_bucket.private_bucket.arn}/*"
    ]
  }
}

# EC2 Instance Profile for IAM Role
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2InstanceProfile"
  role = aws_iam_role.ec2_role.name
}







#######################################
# SNS Topic for Email Verification
#######################################
resource "aws_sns_topic" "email_verification" {
  name = "email-verification-topic"

  tags = {
    Name = "EmailVerificationTopic"
  }
}






#######################################
# IAM Role for Lambda Function
#######################################
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "LambdaExecutionRole"
  }
}

# IAM Policy for Lambda to interact with SNS, RDS, and CloudWatch
resource "aws_iam_policy" "lambda_sns_rds_policy" {
  name        = "lambda_sns_rds_policy"
  description = "Policy to allow Lambda to interact with SNS, RDS, and VPC"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sns:Publish",
          "sns:Subscribe"
        ],
        Resource = aws_sns_topic.email_verification.arn
      },
      {
        Effect = "Allow",
        Action = [
          "rds:DescribeDBInstances",
          "rds:Connect"
        ],
        Resource = aws_db_instance.db_instance.arn
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = "logs:*",
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })

  tags = {
    Name = "LambdaSNSRDSPolicy"
  }
}


# Attach the IAM policy to the Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_sns_rds_policy.arn
}

#######################################
# Lambda Function for Email Verification
#######################################
resource "aws_lambda_function" "email_verification_function" {
  filename      = "C:\\Users\\cheta\\Desktop\\csye6225-assignment\\serverless_forked\\serverless.zip"
  function_name = "email_verification"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30
  memory_size   = 256

  environment {
    variables = {
      DB_HOST = regex("^([^:]+)", aws_db_instance.db_instance.endpoint)[0]
      #aws_db_instance.db_instance.endpoint

      DB_NAME     = var.db_name
      DB_USERNAME = var.username
      #DB_PASSWORD         = aws_secretsmanager_secret.rds_password_secret.id
      SNS_TOPIC_ARN       = aws_sns_topic.email_verification.arn
      SENDGRID_FROM_EMAIL = var.ses_from_email
      REGION              = var.region
      #SENDGRID_API_KEY    = var.sendgrid_api_key
      DB_PORT              = 5432
      DOMAIN_NAME          = "${var.profile}.${var.domain_name}"
      RDS_SECRET_NAME      = aws_secretsmanager_secret.rds_password_secret.id
      SENDGRID_SECRET_NAME = aws_secretsmanager_secret.email_service_secret.id


    }
  }


  # VPC configuration for secure private resource access
  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id, aws_subnet.private_subnet_3.id] # Subnets for Lambda
    security_group_ids = [aws_security_group.lambda_security_group.id]                                                    # Security group for Lambda
  }


  tags = {
    Name = "EmailVerificationLambda"
  }
}




#######################################
# SNS Topic Subscription for Lambda
#######################################
resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.email_verification.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.email_verification_function.arn

  depends_on = [aws_lambda_function.email_verification_function]
}

#######################################
# Permissions for SNS to Invoke Lambda
#######################################
resource "aws_lambda_permission" "sns_permission" {
  statement_id  = "AllowSNSToInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_verification_function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.email_verification.arn
}


#######################################
# NAT Gateway
#######################################

# Allocate an Elastic IP for the NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "${var.vpc_name}-nat-eip"
  }
}

# Create the NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "${var.vpc_name}-nat-gateway"
  }
}

# Add NAT Gateway route in private route table
resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}



data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_acm_certificate" "certficate_issued" {
  domain   = "${var.profile}.${var.domain_name}"
  statuses = ["ISSUED"]
}


# HTTPS Listener
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_load_balancer.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  certificate_arn = data.aws_acm_certificate.certficate_issued.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}


# Listener for Load Balancer
#resource "aws_lb_listener" "app_listener" {
#  load_balancer_arn = aws_lb.app_load_balancer.arn
#  port              = 80
#  protocol          = "HTTP"

#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.app_target_group.arn
#  }
#}



#######################################
# KMS Keys
#######################################

# Get AWS Account ID
data "aws_caller_identity" "current" {}

# Generate a Random Password for RDS
resource "random_password" "rds_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*+-=?^_{|}~"
}


# KMS Key for EC2
resource "aws_kms_key" "ec2_key" {
  description             = "KMS key for EC2 volumes"
  enable_key_rotation     = true
  deletion_window_in_days = 10
}

# KMS Key for RDS
resource "aws_kms_key" "rds_key" {
  description             = "KMS key for RDS"
  enable_key_rotation     = true
  deletion_window_in_days = 10
}

# KMS Key for S3 Buckets
resource "aws_kms_key" "s3_key" {
  description             = "KMS key for S3 bucket encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 10
}

# KMS Key for Secrets Manager
resource "aws_kms_key" "secretsmanager_key" {
  description             = "KMS key for encrypting Secrets Manager secrets"
  enable_key_rotation     = true
  deletion_window_in_days = 10
}



# Secrets Manager for RDS Password
resource "aws_secretsmanager_secret" "rds_password_secret" {
  name       = "rds-db-password-${random_uuid.s3_bucket_name.result}"
  kms_key_id = aws_kms_key.secretsmanager_key.arn

  tags = {
    Name = "RDSPasswordSecret"
  }
}

resource "aws_secretsmanager_secret_version" "rds_password_secret_version" {
  secret_id = aws_secretsmanager_secret.rds_password_secret.id
  secret_string = jsonencode({
    username = var.username
    password = random_password.rds_password.result
  })
}


# Secrets Manager for Email Service Credentials
resource "aws_secretsmanager_secret" "email_service_secret" {
  name       = "email-service-credentials-${random_uuid.s3_bucket_name.result}"
  kms_key_id = aws_kms_key.secretsmanager_key.arn

  tags = {
    Name = "EmailServiceSecret"
  }
}

resource "aws_secretsmanager_secret_version" "email_service_secret_version" {
  secret_id = aws_secretsmanager_secret.email_service_secret.id
  secret_string = jsonencode({
    api_key = var.sendgrid_api_key

  })
}



resource "aws_iam_policy" "ec2_secretsmanager_policy" {
  name        = "EC2SecretsManagerAccessPolicy"
  description = "Policy to allow EC2 instances to access Secrets Manager"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        #"${aws_secretsmanager_secret.rds_password_secret.arn}"
        Resource : [
          aws_secretsmanager_secret.rds_password_secret.arn,
          aws_secretsmanager_secret.email_service_secret.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_secretsmanager_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_secretsmanager_policy.arn
}

resource "aws_iam_policy" "ec2_kms_policy" {
  name        = "EC2KMSAccessPolicy"
  description = "Policy to allow EC2 instances to decrypt Secrets Manager keys"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ],
        Resource : ["${aws_kms_key.secretsmanager_key.arn}",
        "${aws_kms_key.s3_key.arn}"]
      }
    ]
  })
}



resource "aws_iam_role_policy_attachment" "ec2_kms_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_kms_policy.arn
}

resource "aws_iam_policy" "lambda_secretsmanager_policy" {
  name        = "LambdaSecretsManagerAccessPolicy"
  description = "Policy for Lambda to access Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ],
        Resource = [
          aws_kms_key.secretsmanager_key.arn
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = [
          "${aws_secretsmanager_secret.rds_password_secret.arn}",
          "${aws_secretsmanager_secret.email_service_secret.arn}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_secretsmanager_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_secretsmanager_policy.arn
}
#######################################
# Outputs
#######################################

output "s3_bucket_name" {
  value = aws_s3_bucket.private_bucket.bucket
}


output "route53_dns" {
  value = "http://${var.profile}.${var.domain_name}:${var.application_port}/"
}

output "security_group_lambda" {
  value = aws_security_group.lambda_security_group.id
}


output "route53_record_name" {
  value       = "${var.profile}.${var.domain_name}"
  description = "Dynamically constructed Route 53 record name"
}


#output "subnet_ids" {
#  value = [
#    aws_subnet.private_subnet_1.id,
#    aws_subnet.private_subnet_2.id,
#    aws_subnet.private_subnet_3.id
#  ]
#}
#output "vpc_id" {
#  value = aws_vpc.vpc_network.id
#}
