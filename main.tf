

data "hcp_hvn" "main" {
  hvn_id = var.hvn_id
}

data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_arn" "main" {
  arn = data.aws_vpc.main.arn
}

resource "aws_vpc_peering_connection_accepter" "main" {
  vpc_peering_connection_id = hcp_aws_network_peering.main.provider_peering_id
  auto_accept               = true
}

resource "hcp_aws_network_peering" "main" {
  hvn_id          = data.hcp_hvn.main.hvn_id
  peering_id      = var.vault_cluster_id
  peer_vpc_id     = data.aws_vpc.main.id
  peer_account_id = data.aws_vpc.main.owner_id
  peer_vpc_region = data.aws_arn.main.region
}

resource "hcp_hvn_route" "main" {
  hvn_link         = data.hcp_hvn.main.self_link
  hvn_route_id     = "${var.vault_cluster_id}-aws"
  destination_cidr = data.aws_vpc.main.cidr_block
  target_link      = hcp_aws_network_peering.main.self_link
}

data "hcp_vault_cluster" "main" {
  cluster_id = var.vault_cluster_id
}