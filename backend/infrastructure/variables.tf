variable "rg_name" {
  type        = string
  description = "The resource group name"
}

variable "storage_account_name" {
  type        = string
  description = "The globally unique storage account name"
}

variable "location" {
  type        = string
  description = "The location of the resource"
}

variable "cosmosdb_name" {
  type        = string
  description = "The name of the Cosmos DB account name"
}

variable "db_name" {
  type        = string
  description = "The database name for the counter"
}

variable "db_container" {
  type        = string
  description = "The container withint the database that contains the count value"
}

variable "app_service_plan_name" {
  type        = string
  description = "plan-counter"
}

variable "function_app" {
  type        = string
  description = "The function app name"
}

variable "cdn_profile_name" {
  type        = string
  description = "The name of the CDN profile"
}

variable "cdn_endpoint_name" {
  type        = string
  description = "The name of the CDN endpoint"
}

variable "custom_domain_profile" {
  type        = string
  description = "The name of the custom domain profile"
}

variable "custom_domain" {
  type        = string
  description = "The custom hostname"
}

variable "endpoint_hostname" {
  type        = string
  description = "The endpoint hostname for CORS origin setup"
}