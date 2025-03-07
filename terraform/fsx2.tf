resource "aws_fsx_ontap_file_system" "eksfs2" {
  storage_capacity    = 1024
  subnet_ids          = [module.vpc2.private_subnets[0]]
  deployment_type     = "SINGLE_AZ_1"
  throughput_capacity = 128
  preferred_subnet_id = module.vpc2.private_subnets[0]
  security_group_ids  = [aws_security_group.fsx_sg2.id]
  fsx_admin_password  = random_string.fsx_password.result
  tags = {
    Name = var.fsxnamedr
  }
}

resource "aws_fsx_ontap_storage_virtual_machine" "ekssvm2" {
  file_system_id     = aws_fsx_ontap_file_system.eksfs2.id
  name               = "ekssvmdr"
  svm_admin_password = random_string.fsx_password.result
}

resource "aws_security_group" "fsx_sg2" {
  name_prefix = "security group for fsx access"
  vpc_id      = module.vpc2.vpc_id
  tags = {
    Name = "fsx_sg2"
  }
}

resource "aws_security_group_rule" "fsx_sg2_inbound" {
  description       = "allow inbound traffic to fsxn"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  security_group_id = aws_security_group.fsx_sg2.id
  type              = "ingress"
  cidr_blocks       = [var.vpc2_cidr, var.vpc_cidr]
}

resource "aws_security_group_rule" "fsx_sg2_outbound" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.fsx_sg2.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
