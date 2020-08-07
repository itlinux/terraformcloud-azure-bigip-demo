# Main

# Azure Provider
provider "azurerm" {
  features {}
}

# Create a Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}_rg"
  location = var.location
}

# Create Log Analytic Workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.prefix}-law"
  sku                 = "PerNode"
  retention_in_days   = 300
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

# Create the Storage Account
resource "azurerm_storage_account" "mystorage" {
  name                     = "${var.prefix}mystorage"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment             = var.environment
    owner                   = var.owner
    group                   = var.group
    costcenter              = var.costcenter
    application             = var.application
    f5_cloud_failover_label = var.f5_cloud_failover_label
  }
}
