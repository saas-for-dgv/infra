variable "app_service_name" {
  type        = string
  description = "The name of the Azure App Service"
}

variable "rg_name" {
  type        = string
  description = "Resource group name for the App Service"
}

variable "rg_location" {
  type        = string
  description = "Location for the App Service resource group"
}

variable "location_from_parent" {
  type        = string
  description = "Location from the parent module"
}

variable "service_principal_id" {
  type        = string
  description = "Id of the service principal"
}

resource "azurerm_app_service_source_control" "AzAppServiceSrcCtrl" {
  app_id              = azurerm_linux_web_app.linux_webapp.id
  repo_url            = "https://github.com/inepay/api-level-1.git"
  branch              = "gh-pages"  # Specify the branch you want to deploy from

}

resource "azurerm_service_plan" "app_service_plan" {
  name                = "${var.app_service_name}-plan"
  location            = var.location_from_parent
  resource_group_name = var.rg_name

  os_type             = "Linux"
  sku_name            = "P1v2" # "B1", 

  #sku {
  #  tier = "Basic"
  #  size = "B1"
  #}

  tags = {
    environment = "production"
  }
}

resource "azurerm_linux_web_app" "linux_webapp" {
  name                = var.app_service_name
  resource_group_name = var.rg_name
  location            = var.rg_location
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {
    application_stack {
      java_server         = "JAVA"
      java_version        = "java17"
      java_server_version = "17"
    }
  }
}

# In the future if you need to re-use this for other resources/services, then move this out 1 level up
resource "azurerm_role_assignment" "api-level1-role-assignement" {
  scope              = azurerm_linux_web_app.linux_webapp.id  # Scope of the Azure App Service
  principal_id       = var.service_principal_id  # ID of the service principal
  role_definition_id = "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"  # Contributor role ID
}
