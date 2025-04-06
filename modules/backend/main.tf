# SSH Key for the backend host

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

# Launch template for backend instances.

resource "aws_launch_template" "three_tier_backend" {
  name_prefix            = "three_tier_backend"
  instance_type          = var.instance_type
  image_id               = var.image_id
  key_name               = var.key_name
  vpc_security_group_ids = [var.backend_sg]

  tags = {
    Name = "three_tier_backend"
  }
}

# Autoscaling groups for backend hosts.

resource "aws_autoscaling_group" "three_tier_backend" {
  name                = "three_tier_backend"
  vpc_zone_identifier = var.private_backend_subnets
  min_size            = 1
  max_size            = 3
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.three_tier_backend.id
    version = "$Latest"
  }
}
