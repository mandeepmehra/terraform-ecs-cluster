locals {
  cluster_name = "ecsdemo"
}
resource "aws_ecs_cluster" "ecs" {
  name = local.cluster_name
}