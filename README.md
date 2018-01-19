Deploys a group of Cloud-Init enabled Virtual Machines in a Scale Set
==============================================================================

This Terraform module deploys a Virtual Machines Scale Set in Azure, initializes the VMs using Cloud-int for [cloud-init-enabled virtual machine images](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/using-cloud-init), and returns the id of the VM scale set deployed.  

[![Build Status](https://travis-ci.org/Azure/terraform-vmss-cloudinit.svg?branch=master)](https://travis-ci.org/Azure/terraform-vmss-cloudinit)

This module requires a network and loadbalancer to be provided separately such as the "Azure/network/azurerm" and "Azure/loadbalancer/azurerm" modules.

Visit [this website](http://cloudinit.readthedocs.io/en/latest/index.html) for more information about cloud-init. Some quick tips:
- Troubleshoot logging via `/var/log/cloud-init.log`
- Relevant applied cloud configuration information can be found in the `/var/lib/cloud/instance` directory
- By default this module will create a new txt file `/tmp/terraformtest` to validate if cloud-init worked

To override the cloud-init configuration, place a file called `cloudconfig.tpl` in the root of the module directory with the cloud-init contents or update the `cloudconfig_file` variable with the location of the file containing the desired configuration.

Valid values for `vm_os_simple` are the latest versions of:
  - UbuntuServer   = 16.04-LTS
  - UbuntuServer14 = 14.04.5-LTS
  - RHEL           = RedHat Enterprise Linux 7
  - CentOS         = CentOS 7
  - CoreOS         = CoreOS Stable

Usage
-----

```hcl 
provider "azurerm" {
  version = "~> 1.0"
}

variable "resource_group_name" {
  default = "terraform-vmss-cloudinit"
}

variable "location" {
  default = "eastus"
}

module "network" {
  source              = "Azure/network/azurerm"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

module "loadbalancer" {
  source              = "Azure/loadbalancer/azurerm"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"
  prefix              = "terraform-test"

  "remote_port" {
    ssh = ["Tcp", "22"]
  }

  "lb_port" {
    http = ["80", "Tcp", "80"]
  }
}

module "vmss-cloudinit" {
  source                                 = "Azure/vmss-cloudinit/azurerm"
  resource_group_name                    = "${var.resource_group_name}"
  cloudconfig_file                       = "${path.module}/cloudconfig.tpl"
  location                               = "${var.location}"
  vm_size                                = "Standard_DS2_v2"
  admin_username                         = "azureuser"
  admin_password                         = "ComplexPassword"
  ssh_key                                = "~/.ssh/id_rsa.pub"
  nb_instance                            = 2
  vm_os_simple                           = "UbuntuServer"
  vnet_subnet_id                         = "${module.network.vnet_subnets[0]}"
  load_balancer_backend_address_pool_ids = "${module.loadbalancer.azurerm_lb_backend_address_pool_id}"
}

output "vmss_id" {
  value = "${module.vmss-cloudinit.vmss_id}"
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
