variable "project"  {
    type =string
}

variable "environment"  {
    type = string
    validation {
        condition = contains(["prod","dev","uat"], var.environment)
        error_message = "Environments should be one of dev, qa, uat or prod"
    }
}

variable "vpc_tags"  {
    type = map
    default = {}
}

variable "vpc_cidr"  {
    type = string 
    default = "10.0.0.0/16"
}
