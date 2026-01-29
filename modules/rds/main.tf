# DB Subnet Group - Groups private subnets for RDS placement
resource "aws_db_subnet_group" "this" {
  name       = "${var.env}-rds-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.project_tags, {
    Name = "${var.env}-rds-subnet-group"
  })
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name        = "${var.env}-rds-sg"
  description = "Security group for RDS MySQL instance"
  vpc_id      = var.vpc_id

  tags = merge(var.project_tags, {
    Name = "${var.env}-rds-sg"
  })
}

# Security Group Rule - Ingress (MySQL from VPC)
resource "aws_vpc_security_group_ingress_rule" "mysql" {
  security_group_id = aws_security_group.rds.id
  description       = "Allow MySQL traffic from VPC"

  cidr_ipv4   = var.vpc_cidr
  from_port   = 3306
  to_port     = 3306
  ip_protocol = "tcp"

  tags = merge(var.project_tags, {
    Name = "${var.env}-rds-mysql-ingress"
  })
}

# Security Group Rule - Egress (All traffic for maintenance/updates)
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.rds.id
  description       = "Allow all outbound traffic for maintenance and updates"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = merge(var.project_tags, {
    Name = "${var.env}-rds-egress"
  })
}

# DB Parameter Group - Custom MySQL configuration
resource "aws_db_parameter_group" "this" {
  name   = "${var.env}-mysql-params"
  family = "mysql8.0"

  tags = merge(var.project_tags, {
    Name = "${var.env}-mysql-params"
  })
}

# RDS MySQL Instance
resource "aws_db_instance" "this" {
  identifier = "${var.env}-mysql-db"

  # Engine Configuration
  engine         = "mysql"
  engine_version = var.engine_version
  instance_class = var.instance_class

  # Storage Configuration
  allocated_storage     = var.allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  max_allocated_storage = var.allocated_storage * 2 # Enable storage autoscaling

  # Database Configuration
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 3306

  # Network Configuration
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  multi_az               = false # Single-AZ for dev

  # Parameter and Option Groups
  parameter_group_name = aws_db_parameter_group.this.name

  # Backup Configuration
  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"    # 3-4 AM UTC
  maintenance_window      = "mon:04:00-mon:05:00" # Monday 4-5 AM UTC

  # Snapshot Configuration
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.env}-mysql-db-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # Deletion Protection
  deletion_protection = false # Set to true for production

  # Monitoring
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  tags = merge(var.project_tags, {
    Name = "${var.env}-mysql-db"
  })
}
