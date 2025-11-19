resource "aws_subnet" "pub_sub" {
  count                   = length(var.pub_sub_cidr)
  vpc_id                  = var.vpc_id
  availability_zone       = element(var.azs, count.index)
  cidr_block              = element(var.pub_sub_cidr, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "pub_subnet-${count.index}"
  }
}

resource "aws_subnet" "private_sub" {
  count                   = length(var.private_sub_cidr)
  vpc_id                  = var.vpc_id
  availability_zone       = element(var.azs, count.index)
  cidr_block              = element(var.private_sub_cidr, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "private_subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_eip" "eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.pub_sub[0].id

  tags = {
    Name = "gw NAT"
  }
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "private_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = {
    Name = "private-route-table"
  }
}


resource "aws_route_table_association" "pub_rt_association" {
  count          = length(var.pub_sub_cidr)
  subnet_id      = aws_subnet.pub_sub[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rt_association" {
  count          = length(var.private_sub_cidr)
  subnet_id      = aws_subnet.private_sub[count.index].id
  route_table_id = aws_route_table.private_rt.id
}