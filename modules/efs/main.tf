# Creates the EFS file system for Jenkins persistent storage.
resource "aws_efs_file_system" "this" {
  creation_token = var.efs_name
  tags           = merge(var.tags, { Name = var.efs_name })
}

# Creates a security group for the EFS that allows NFS traffic from EKS worker nodes.
resource "aws_security_group" "efs_sg" {
  name        = "${var.efs_name}-sg"
  description = "Allow EKS nodes to access EFS via NFS"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 2049 # NFS
    to_port         = 2049
    security_groups = [var.node_security_group_id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.efs_name}-sg" })
}

# Creates a mount target in each specified subnet.
resource "aws_efs_mount_target" "this" {
  count = length(var.subnet_ids)

  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [aws_security_group.efs_sg.id]
} 