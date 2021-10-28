resource "aws_vpc" "ecsvpc" {
  cidr_block = "10.32.0.0/16"
}


data "aws_availability_zones" "allazs" {

}

resource "aws_subnet" "public" {
  count = length(data.aws_availability_zones.allazs.names)
  cidr_block = "10.32.${count.index}.0/28"
  availability_zone = data.aws_availability_zones.allazs.names[count.index]
  vpc_id = aws_vpc.ecsvpc.id
}

resource "aws_subnet" "private" {
  count = length(data.aws_availability_zones.allazs.names)
  cidr_block = "10.32.${10 + count.index}.0/28"
  availability_zone = data.aws_availability_zones.allazs.names[count.index]
  vpc_id = aws_vpc.ecsvpc.id
}

resource "aws_internet_gateway" "igw" {
   vpc_id = aws_vpc.vpc.id
 
}