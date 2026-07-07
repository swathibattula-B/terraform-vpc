locals {

    common_tags = {
            project = "roboshop"
            environment = "environment"
            terraform = "true"
        } 
    

    vpc_final_tags = merge(
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}"
        },
        var.vpc_tags
    )

    igw_final_tags = merge(
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}"
        },
        var.igw_tags
    )

    azs = slice(data.aws_availability_zones.available.names, 0, 2)

}