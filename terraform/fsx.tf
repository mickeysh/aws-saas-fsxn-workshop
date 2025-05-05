
resource "random_string" "fsx_password" {
  length           = 8
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  numeric          = true
  special          = true
  override_special = "!"
}

resource "aws_fsx_ontap_file_system" "eksfs" {
  storage_capacity    = 1024
  subnet_ids          = [module.vpc.private_subnets[0]]
  deployment_type     = "SINGLE_AZ_1"
  throughput_capacity = 128
  preferred_subnet_id = module.vpc.private_subnets[0]
  security_group_ids  = [aws_security_group.fsx_sg.id]
  fsx_admin_password  = random_string.fsx_password.result
  tags = {
    Name = var.fsxname
  }
}

resource "aws_fsx_ontap_storage_virtual_machine" "ekssvm" {
  file_system_id     = aws_fsx_ontap_file_system.eksfs.id
  name               = "ekssvm"
  svm_admin_password = random_string.fsx_password.result
}

resource "aws_fsx_ontap_storage_virtual_machine" "ekssvmt2" {
  file_system_id     = aws_fsx_ontap_file_system.eksfs.id
  name               = "ekssvmt2"
  svm_admin_password = random_string.fsx_password.result
}

resource "aws_security_group" "fsx_sg" {
  name_prefix = "security group for fsx access"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name = "fsx_sg"
  }
}

resource "aws_security_group_rule" "fsx_sg_inbound" {
  description       = "allow inbound traffic to fsxn"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  security_group_id = aws_security_group.fsx_sg.id
  type              = "ingress"
  cidr_blocks       = [var.vpc_cidr, var.vpc2_cidr]
}

resource "aws_security_group_rule" "fsx_sg_outbound" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.fsx_sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
