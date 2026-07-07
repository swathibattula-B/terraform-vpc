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

resource "aws_subnet" "public" {
  count = length(var.public_subnet)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet[count.index]
  map_public_ip_on_launch = true
  availability_zone = local.azs[count.index]

  tags = merge (local.common_tags,
    {
    Name = "${var.project}-${var.environment}-public-subnet-${local.azs[count.index]}"
    },
    var.public_subnet_tags
  )
}

