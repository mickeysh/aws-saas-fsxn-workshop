module "vpc2" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.18.1"

  name                 = "fsxn-saas-vpc2"
  cidr                 = var.vpc2_cidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnets       = ["10.1.4.0/24", "10.1.5.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}


resource "aws_vpc_peering_connection" "vpc_peer" {
  peer_vpc_id = module.vpc2.vpc_id
  vpc_id      = module.vpc.vpc_id
  auto_accept = true
  tags = {
    Name = "fsxn-saas-vpc-peer"
  }
}

resource "aws_vpc_peering_connection_accepter" "vpc_peer" {
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer.id
  auto_accept               = true

  tags = {
    Name = "fsxn-saas-vpc-peer"
  }
}


resource "aws_route" "peer_vpc_private_route" {
  route_table_id            = module.vpc.private_route_table_ids[0]
  destination_cidr_block    = var.vpc2_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer.id
}

resource "aws_route" "peer_vpc_public_route" {
  route_table_id            = module.vpc.public_route_table_ids[0]
  destination_cidr_block    = var.vpc2_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer.id
}

resource "aws_route" "peer_vpc2_private_route" {
  route_table_id            = module.vpc2.private_route_table_ids[0]
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer.id
}

resource "aws_route" "peer_vpc2_public_route" {
  route_table_id            = module.vpc2.public_route_table_ids[0]
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer.id
}