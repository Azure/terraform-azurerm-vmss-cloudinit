provider "azurerm" {
  version = "~> 1.0"
}

variable "resource_group_name" {
  default = "terraform-vmss-cloudinit"
}

module "network" {
  source              = "Azure/network/azurerm"
  location            = "westus"
  allow_ssh_traffic   = "true"
  resource_group_name = "${var.resource_group_name}"
}

module "loadbalancer" {
  source              = "Azure/loadbalancer/azurerm"
  resource_group_name = "${var.resource_group_name}"
  location            = "westus"
  prefix              = "terraform-test"

  "lb_port" {
    http = ["80", "Tcp", "80"]
    ssh  = ["22", "Tcp", "22"]
  }
}

module "computegroup" {
  source                                 = ".."
  resource_group_name                    = "${var.resource_group_name}"
  cloudconfig_file                       = "${path.module}/cloudconfig.tpl"
  location                               = "westus"
  vm_size                                = "Standard_DS2_v2"
  admin_username                         = "azureuser"
  admin_password                         = "ComplexPassword"
  ssh_key                                = "~/.ssh/id_rsa.pub"
  nb_instance                            = 1
  vm_os_simple                           = "CentOS"
  vnet_subnet_id                         = "${module.network.vnet_subnets[0]}"
  load_balancer_backend_address_pool_ids = "${module.loadbalancer.azurerm_lb_backend_address_pool_id}"
}

output "vmss_id" {
  value = "${module.computegroup.vmss_id}"
}
