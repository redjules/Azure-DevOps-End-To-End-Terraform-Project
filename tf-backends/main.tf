provider "azurerm" {
  features {}

  subscription_id = "35e9d656-1906-4466-989b-c9ecb2c471e1"
}

module "dev_backend" {
  source = "./modules/backend"
  environment = "dev"
}

module "test_backend" {
  source = "./modules/backend"
  environment = "test"
}

module "prod_backend" {
  source = "./modules/backend"
  environment = "prod"
}