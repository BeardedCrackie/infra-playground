variable "virtual_environment" {
    type = object({
        password = string
        endpoint = string
        username = string
    })
    sensitive = true
} 

variable "project" {
    type = object({
        name = string
    })
} 