# Create a vpc for the application.

resource "aws_vpc" "three_tier_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "three_tier_vpc"
  }
  lifecycle {
    create_before_destroy = true
  }
}


data "aws_availability_zones" "available" {
}

# Create internet gateway
resource "aws_internet_gateway" "three_tier_internet_gateway" {
  vpc_id = aws_vpc.three_tier_vpc.id
  tags = {
    Name = "three_tier_igw"
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Public subnets for bastion host.

resource "aws_subnet" "three_tier_public_subnets" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.three_tier_vpc.id
  cidr_block              = "10.0.${10 + count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "three_tier_public_${count.index + 1}"
  }
}

resource "aws_route_table" "three_tier_public_rt" {
  vpc_id = aws_vpc.three_tier_vpc.id

  tags = {
    Name = "three_tier_public"
  }
}

resource "aws_route_table_association" "three_tier_public_association" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.three_tier_public_subnets.*.id[count.index]
  route_table_id = aws_route_table.three_tier_public_rt.id
}


resource "aws_route" "default_public_route" {
  route_table_id         = aws_route_table.three_tier_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.three_tier_internet_gateway.id
}

resource "aws_security_group" "three_tier_bastion_sg" {
  name        = "three_tier_bastion_sg"
  description = "Allow SSH Inbound Traffic From Set IP"
  vpc_id      = aws_vpc.three_tier_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# Private subnets

# Elastic IP.
resource "aws_eip" "three_tier_nat_eip" {
  vpc = true
}

# NAT Gateway.
resource "aws_nat_gateway" "three_tier_ngw" {
  allocation_id = aws_eip.three_tier_nat_eip.id
  subnet_id     = aws_subnet.three_tier_public_subnets[1].id
}


#Private Subnets for frontend

resource "aws_subnet" "three_tier_private_frontend_subnets" {
  count                   = var.private_frontend_subnet_count
  vpc_id                  = aws_vpc.three_tier_vpc.id
  cidr_block              = "10.0.${20 + count.index}.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "three_tier_private_frontend_${count.index + 1}"
  }
}


resource "aws_subnet" "three_tier_private_backend_subnets" {
  count                   = var.private_backend_subnet_count
  vpc_id                  = aws_vpc.three_tier_vpc.id
  cidr_block              = "10.0.${30 + count.index}.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "three_tier_private_backend_${count.index + 1}"
  }
}

# Route table for private subnets.

resource "aws_route_table" "three_tier_private_rt" {
  vpc_id = aws_vpc.three_tier_vpc.id

  tags = {
    Name = "three_tier_private"
  }
}
# Default Route for private subnets.

resource "aws_route" "default_private_route" {
  route_table_id         = aws_route_table.three_tier_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.three_tier_ngw.id
}

# Route table association for frontend subnets.

resource "aws_route_table_association" "three_tier_private_frontend_assoc" {
  count          = var.private_frontend_subnet_count
  route_table_id = aws_route_table.three_tier_private_rt.id
  subnet_id      = aws_subnet.three_tier_private_frontend_subnets.*.id[count.index]
}

# Route table association for backend subnets.

resource "aws_route_table_association" "three_tier_private_backend_assoc" {
  count          = var.private_backend_subnet_count
  route_table_id = aws_route_table.three_tier_private_rt.id
  subnet_id      = aws_subnet.three_tier_private_backend_subnets.*.id[count.index]
}


# Security groups for frontend subnets.

resource "aws_security_group" "three_tier_frontend_sg" {
  name        = "three_tier_frontend_app_sg"
  description = "Allow SSH inbound traffic from Bastion, and HTTP inbound traffic from loadbalancer"
  vpc_id      = aws_vpc.three_tier_vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.three_tier_bastion_sg.id]
  }
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.three_tier_loadbalancer_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security groups for backend subnets.

resource "aws_security_group" "three_tier_backend_sg" {
  name        = "three_tier_backend_app_sg"
  description = "Allow SSH inbound traffic from Bastion"
  vpc_id      = aws_vpc.three_tier_vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.three_tier_bastion_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security groups for loadbalancer.

resource "aws_security_group" "three_tier_loadbalancer_sg" {
  name        = "three_tier_loadbalancer_sg"
  description = "Allow and HTTP inbound traffic from outside"
  vpc_id      = aws_vpc.three_tier_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Subnets for database.

resource "aws_subnet" "three_tier_private_subnets_db" {
  count                   = var.private_database_subnet_count
  vpc_id                  = aws_vpc.three_tier_vpc.id
  cidr_block              = "10.0.${40 + count.index}.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "three_tier_private_db${count.index + 1}"
  }
}

# Subnet group for Database.

resource "aws_db_subnet_group" "three_tier_rds_subnetgroup" {
  count      = var.db_subnet_group == true ? 1 : 0
  name       = "three_tier_rds_subnetgroup"
  subnet_ids = [aws_subnet.three_tier_private_subnets_db[0].id, aws_subnet.three_tier_private_subnets_db[1].id]

  tags = {
    Name = "three_tier_database_subnet"
  }
}

# Security group for database.

resource "aws_security_group" "three_tier_rds_sg" {
  name        = "three-tier_rds_sg"
  description = "Allow MySQL Port Inbound Traffic from Backend App Security Group"
  vpc_id      = aws_vpc.three_tier_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.three_tier_backend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


