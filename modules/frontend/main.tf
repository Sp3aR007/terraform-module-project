# SSH Key for the frontend host

resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Generate a public key for aws and associate with private key.

resource "aws_key_pair" "generated_key" {
  key_name   = var.ssh_key
  public_key = tls_private_key.main.public_key_openssh
}

# Save the private key locally with readonly permissions.

resource "local_file" "ssh_key" {
  content         = tls_private_key.main.private_key_pem
  filename        = "${var.ssh_key}.pem"
  file_permission = "0400"
}

# Launch template for frontend instances.

resource "aws_launch_template" "three_tier_frontend" {
  name_prefix            = "three_tier_frontend"
  instance_type          = var.instance_type
  image_id               = var.image_id
  key_name               = var.key_name
  vpc_security_group_ids = [var.frontend_sg]
  user_data              = filebase64("install_nginx.sh")

  tags = {
    Name = "three_tier_frontend"
  }
}

# Autoscaling groups for frontend hosts.

resource "aws_autoscaling_group" "three_tier_frontend" {
  name                = "three_tier_frontend"
  vpc_zone_identifier = var.private_frontend_subnets
  min_size            = 1
  max_size            = 3
  desired_capacity    = 1
  target_group_arns        = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.three_tier_frontend.id
    version = "$Latest"
  }
}
