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

}