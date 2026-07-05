variable "project"  {
    type =string
}

variable "environment"  {
    type =string
    validate {
        condition = contains(["prod","dev","uat"], var.environment)
        errorMessege = "vpx should selct one environment"
    }
}

variable "vpc_tags"  {
    type = map
}

variable "vpc_cidr"  {
    type = string 
    default = ["10.0.0.0/16"]
}
