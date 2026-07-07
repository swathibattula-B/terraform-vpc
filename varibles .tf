variable "project" {
    type = string
}
variable "environment" {
    type = string
    validation {
        condition = contains(["uat","dev","prod"], var.environment)
        error_message = "Environments should be one of dev, qa, uat or prod"
    }
}

variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
}

variable "vpc_tags" {
    type = map
    default = {}
}

variable "igw_tags" {
    type = map
    default = {}
}


