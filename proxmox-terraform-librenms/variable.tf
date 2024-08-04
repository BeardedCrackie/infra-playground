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