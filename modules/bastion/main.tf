# SSH Key for the bastion host

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

# Launch template for bastion host.

resource "aws_launch_template" "three_tier_bastion" {
  name_prefix            = "three_tier_bastion"
  instance_type          = var.instance_type
  image_id               = var.image_id
  key_name               = var.key_name
  vpc_security_group_ids = [var.bastion_sg]

  tags = {
    Name = "three_tier_bastion"
  }
}

# Autoscaling groups for bastion host.

resource "aws_autoscaling_group" "three_tier_bastion" {
  name                = "three_tier_bastion"
  vpc_zone_identifier = var.public_subnets
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.three_tier_bastion.id
    version = "$Latest"
  }
}
