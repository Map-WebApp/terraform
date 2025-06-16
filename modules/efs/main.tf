resource "aws_efs_file_system" "this" {
  creation_token = var.efs_name
  tags           = merge(var.tags, { Name = var.efs_name })
}

resource "aws_security_group" "efs_sg" {
  name        = "${var.efs_name}-sg"
  description = "Allow EKS nodes to access EFS"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 2049 // NFS
    to_port         = 2049
    security_groups = [var.node_sg_id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.efs_name}-sg" })
}

resource "aws_efs_mount_target" "this" {
  for_each = toset(var.subnet_ids)

  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.key
  security_groups = [aws_security_group.efs_sg.id]
} 