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

# public subnet

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

# private subnet

resource "aws_subnet" "private" {
  count = length(var.private_subnet)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet[count.index]
  availability_zone = local.azs[count.index]

  tags = merge (local.common_tags,
    {
    Name = "${var.project}-${var.environment}-private-subnet-${local.azs[count.index]}"
    },
    var.private_subnet_tags
  )
}

# database_subnet

resource "aws_subnet" "database" {
  count = length(var.database_subnet)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet[count.index]
  availability_zone = local.azs[count.index]

  tags = merge (local.common_tags,
    {
    Name = "${var.project}-${var.environment}-database-subnet-${local.azs[count.index]}"
    },
    var.database_subnet_tags
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id


  tags = merge (
        local.common_tags ,
        {
          Name = "${var.project}-${var.environment}-public"
        },
        var.public_route_table_tags
  )

}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id


  tags = merge (
        local.common_tags ,
        {
          Name = "${var.project}-${var.environment}-private"
        },
        var.private_route_table_tags
  )

}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id


  tags = merge (
        local.common_tags ,
        {
          Name = "${var.project}-${var.environment}-database"
        },
        var.database_route_table_tags
  )

}


resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}


resource "aws_eip" "nat" {
  domain                    = "vpc"
  
  tags = merge(
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}-nat"
        },
        var.eip_tags
  )
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = merge (
        local.common_tags ,
        {
          Name = "${var.project}-${var.environment}-nat"
        },
        var.aws_nat_gateway_tags
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id  = aws_nat_gateway.main.id
}

resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id  = aws_nat_gateway.main.id
}


resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = var.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = var.private_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id      = var.database_subnet[count.index].id
  route_table_id = aws_route_table.database.id
}