// grab the availability zones for the region we set in var.tf
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = local.tag_name
  }
}

resource "aws_subnet" "public" {
  cidr_block              = var.cidr_block_subnet_public
  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.tag_name}-public"
  }
}

// RDS cluster in serverless mode requires at least 3 AZs

resource "aws_subnet" "private" {
  count = length(var.cidr_block_subnets_private)
  // name  = "${local.tag_name}-private-${count.index}"

  cidr_block        = var.cidr_block_subnets_private[count.index]
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${local.tag_name}-private-${count.index}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = local.tag_name
  }
}

// NAT gateway requires an elastic ip
resource "aws_eip" "public" {
  vpc      = true
  tags = {
    Name = local.tag_name
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.public.id
  // connect to public subnet
  subnet_id = aws_subnet.public.id
  tags = {
    Name = local.tag_name
  }
}

// Output the subnet ids which will be used in the serverless.yml later
output "subnet_private" {
  value = tolist(aws_subnet.private.*.id)
}
