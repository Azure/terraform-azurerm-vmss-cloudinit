provider "azurerm" {
  version = "~> 1.0"
}

resource "random_id" "ip_dns" {
  byte_length = 8
}

module "network" {
  source              = "Azure/network/azurerm"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}-${random_id.ip_dns.hex}"
}

module "loadbalancer" {
  source              = "Azure/loadbalancer/azurerm"
  resource_group_name = "${var.resource_group_name}-${random_id.ip_dns.hex}"
  location            = "${var.location}"
  prefix              = "terraform-test"

  "lb_port" {
    http = ["80", "Tcp", "80"]
    ssh  = ["22", "Tcp", "22"]
  }
}

module "computegroup" {
  source                                 = "../../"
  resource_group_name                    = "${var.resource_group_name}"
  cloudconfig_file                       = "../../cloudconfig.tpl"
  location                               = "${var.location}"
  vm_size                                = "Standard_DS2_v2"
  admin_username                         = "azureuser"
  admin_password                         = "ComplexPassword"
  ssh_key                                = "${var.ssh_key}"
  nb_instance                            = 1
  vm_os_simple                           = "${var.vm_os_simple}"
  vnet_subnet_id                         = "${module.network.vnet_subnets[0]}"
  load_balancer_backend_address_pool_ids = "${module.loadbalancer.azurerm_lb_backend_address_pool_id}"
}
