variable "sql_server_name" {
    description = "The name of the sql_server_name"
    type        = string
 
 }
 variable "rg_name" {
    description = "The name of the resource group"
    type        = string
 
 }
 variable "location" {
    description = "The name of the location"
    type        = string
 
 }
/*variable "key_vault_name" {
  type = string
}*/
variable "admin_username" {
  type = string
}
variable "admin_password" {
  type = string
}