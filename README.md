Deploys a group of Cloud-Init enabled Virtual Machines in a Scale Set
==============================================================================

This Terraform module deploys a Virtual Machines Scale Set in Azure, initializes the VMs using Cloud-int for [cloud-init-enabled virtual machine images](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/using-cloud-init), and returns the id of the VM scale set deployed.

This module requires a network and loadbalancer to be provider separately. You can provision them with the "Azure/network/azurerm" and "Azure/loadbanacer/azurerm" modules.

[![Build Status](https://travis-ci.org/Azure/terraform-vmss-cloudinit.svg?branch=master)](https://travis-ci.org/Azure/terraform-vmss-cloudinit)

Usage
-----

```hcl 
provider "azurerm" {
  version = "~> 1.0"
}

variable "resource_group_name" {
    default = "terraform-vmss-cloudinit"
}

module "network" {
    source = "Azure/network/azurerm"
    location = "westus"
    allow_ssh_traffic = "true"
    resource_group_name = "${var.resource_group_name}"
  }

module "loadbalancer" {
  source = "Azure/loadbalancer/azurerm"
  resource_group_name = "${var.resource_group_name}"
  location = "westus"
  prefix = "terraform-test"
  "lb_port" {
      http = [ "80", "Tcp", "80"]
      ssh = ["22", "Tcp", "22"]
  }
}

module "computegroup" { 
    source              = ".."
    resource_group_name = "${var.resource_group_name}"
    location            = "westus"
    vm_size             = "Standard_DS2_v2"
    admin_username      = "azureuser"
    admin_password      = "ComplexPassword"
    ssh_key             = "~/.ssh/id_rsa.pub"
    nb_instance         = 1
    vm_os_simple        = "UbuntuServer"
    vnet_subnet_id      = "${module.network.vnet_subnets[0]}"
    load_balancer_backend_address_pool_ids = "${module.loadbalancer.azurerm_lb_backend_address_pool_id}"
    cmd_extension       = "sudo apt-get -y install nginx"
}

output "vmss_id"{
  value = "${module.computegroup.vmss_id}"
}

```

Run Test
-----
Please visit [this repository](https://github.com/Azure/terraform-test) on how to run the tests.

Authors
=======
Originally created by [David Tesar](http://github.com/dtzar)

License
=======

[MIT](LICENSE)
