# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "app_service_rg" {
  name     = "Alpha-ResourceGrp"
  location = var.Location_to_use
}

resource "azuread_application" "my_application" {
  display_name = "ServicePrincipalGithubCreated"
}

resource "azuread_service_principal" "inepay_service_principal" {
  client_id = azuread_application.my_application.client_id
}

resource "azuread_service_principal_password" "inepay_sp_password" {
  service_principal_id = azuread_service_principal.inepay_service_principal.id
  end_date             = "2999-01-01T01:02:03Z"  # Set a date in the future
}

resource "azurerm_source_control_token" "github_token" {
  token              = var.Github_token_from_pipeline
  type               = "GitHub"
}

module "api"{
  source = "./modules/api"
  app_service_name            = "Alpha-AppService"
  location_from_parent        = var.Location_to_use
  rg_name                     = azurerm_resource_group.app_service_rg.name
  rg_location                 = azurerm_resource_group.app_service_rg.location
  service_principal_id        = azuread_service_principal.inepay_service_principal.id
}

#module "app_service_setup" {
#  source = "./modules/app-service"

#  app_service_name            = "Alpha-AppService"
#  rg_name                     = azurerm_resource_group.app_service_rg.name
#  rg_location                 = azurerm_resource_group.app_service_rg.location
#  location_from_parent        = var.Location_to_use
#}

#module "deploy_from_github" {
#  source = "./modules/deploy-from-github"
#  app_service_id  = module.app_service_setup.app_service_id
#}
