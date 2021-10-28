resource "aws_vpc" "ecsvpc" {
  cidr_block = "10.32.0.0/16"
}

locals {
    subnet_count = 2
}

data "aws_availability_zones" "allazs" {

}

resource "aws_subnet" "public" {
  count = local.subnet_count
  cidr_block = "10.32.${count.index}.0/28"
  availability_zone = data.aws_availability_zones.allazs.names[count.index]
  vpc_id = aws_vpc.ecsvpc.id
}

resource "aws_subnet" "private" {
  count = local.subnet_count
  cidr_block = "10.32.${10 + count.index}.0/28"
  availability_zone = data.aws_availability_zones.allazs.names[count.index]
  vpc_id = aws_vpc.ecsvpc.id
}

resource "aws_internet_gateway" "igw" {
   vpc_id = aws_vpc.ecsvpc.id
 
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.ecsvpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_eip" "gateway" {
  count      = local.subnet_count
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "gateway" {
  count         = local.subnet_count
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.gateway.*.id, count.index)
}


resource "aws_route_table" "private" {
  count  = local.subnet_count
  vpc_id = aws_vpc.ecsvpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gateway.*.id, count.index)
  }
}

resource "aws_route_table_association" "private" {
  count          = local.subnet_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}
