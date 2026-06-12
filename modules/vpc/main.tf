# =========================
# VPC
# =========================
resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "terraform-vpc"
  }
}

# =========================
# Internet Gateway
# =========================
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "terraform-vpc-igw"
  }
}

# =========================
# Public Subnet (AZ-A)
# =========================
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-vpc-public-a"
  }
}

# =========================
# Public Subnet (AZ-C)
# =========================
resource "aws_subnet" "public_c" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-vpc-public-c"
  }
}

# =========================
# Private Subnet (AZ-A)
# =========================
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "ap-northeast-1a"

  # 重要：Privateは必ずfalse
  map_public_ip_on_launch = false

  tags = {
    Name = "terraform-vpc-private-a"
  }
}

# =========================
# Private Subnet (AZ-C)
# =========================
resource "aws_subnet" "private_c" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "ap-northeast-1c"

  map_public_ip_on_launch = false

  tags = {
    Name = "terraform-vpc-private-c"
  }
}

# =========================
# Public Route Table
# =========================
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "terraform-vpc-public-rt"
  }
}

# =========================
# Private Route Table
# =========================
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "terraform-vpc-private-rt"
  }
}

resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# =========================
# Public Route Association
# =========================
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public_rt.id
}

# =========================
# Private Route Association
# =========================
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private_rt.id
}


# =========================
# Elastic IP (NAT Gateway用)
# =========================
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "terraform-nat-eip"
  }
}

# =========================
# NAT Gateway
# =========================
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name = "terraform-nat-gateway"
  }

  depends_on = [aws_internet_gateway.igw]
}
