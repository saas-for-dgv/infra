variable "subscription_id" {
  description = "Azure Subscription ID"
}

variable "Location_to_use" {
  type        = string
  description = "The location for the Azure resources"
  default     = "East US"
}

variable "Github_token_from_pipeline" {
  description = "Token to be used in azure for github operations"
}
