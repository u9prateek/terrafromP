terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.25.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}

  subscription_id = "3d276849-1e8c-4f22-a82d-96395060cd16"
  tenant_id       = "99a941a8-d33d-492f-b297-bccbc7a529b1"
  client_id       = "10044ffd-498d-4265-9534-6c938082152b"
  client_secret   = "bum8Q~nwUcxqgfUqi7LPJg8G3Og~qsMTe9bHkaDO"

}