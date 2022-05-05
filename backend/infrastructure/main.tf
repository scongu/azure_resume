terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_storage_account" "st" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  static_website {
    index_document = "index.html"
  }
}

resource "azurerm_cosmosdb_account" "dba" {
  name                = var.cosmosdb_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level = "Eventual"
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }

  backup {
    type                = "Periodic"
    interval_in_minutes = 60
    retention_in_hours  = 8
    storage_redundancy  = "Local"
  }
}

resource "azurerm_cosmosdb_sql_database" "db" {
  name                = var.db_name
  account_name        = azurerm_cosmosdb_account.dba.name
  resource_group_name = azurerm_cosmosdb_account.dba.resource_group_name
}

resource "azurerm_cosmosdb_sql_container" "db_container" {
  name                  = var.db_container
  resource_group_name   = azurerm_cosmosdb_account.dba.resource_group_name
  account_name          = azurerm_cosmosdb_account.dba.name
  database_name         = azurerm_cosmosdb_sql_database.db.name
  partition_key_path    = "/index"
  partition_key_version = 1
}

resource "azurerm_service_plan" "asp" {
  name                = var.app_service_plan_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "function" {
  name                       = var.function_app
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  service_plan_id            = azurerm_service_plan.asp.id
  storage_account_name       = azurerm_storage_account.st.name
  storage_account_access_key = azurerm_storage_account.st.primary_access_key

  site_config {
    cors {
      allowed_origins = [var.endpoint_hostname]
    }
  }

  app_settings = {
    https_only               = true
    FUNCTION_WORKER_RUNTIME  = "python"
    FUNCTION_APP_EDIT_MODE   = "readonly"
    CosmosDbConnectionString = azurerm_cosmosdb_account.dba.connection_strings[0]
  }
}
