resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames  = true

  tags = local.vpc_final_tags
    
    
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = local.igw_final_tags
}

resource "aws_public_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = lenth(var.public_subnet)
  map_public_ip_on_launch = true
  availability_zone = local.azs[count.index]

  tags = tags = {
    Name = "public-subnet-${local.azs[count.index]}"
  }
}

