variable "virtual_environment" {
    type = object({
        password = string
        endpoint = string
        username = string
        node_name = string
        datastore_id = string
    })
    sensitive = true
} 

variable "project" {
    type = object({
        name = string
    })
} 

variable "priv_key" {
    type = string
}

variable "ct_pub_key" {
    type = string
}

variable "ct_name" {
    type = string
}

variable "ct_ip" {
    type = string
}
