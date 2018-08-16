# Deploys a group of Cloud-Init enabled Virtual Machines in a Scale Set
[![Build Status](https://travis-ci.org/Azure/terraform-azurerm-vmss-cloudinit.svg?branch=master)](https://travis-ci.org/Azure/terraform-azurerm-vmss-cloudinit)

This Terraform module deploys a Virtual Machines Scale Set in Azure, initializes the VMs using Cloud-int for [cloud-init-enabled virtual machine images](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/using-cloud-init), and returns the id of the VM scale set deployed.  

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

## Usage

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

## Test

### Configurations

- [Configure Terraform for Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure)
- [Generate and add SSH Key](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/) Save the key in ~/.ssh/id_rsa.  This is not required for Windows deployments.

We provide 2 ways to build, run, and test the module on a local development machine.  [Native (Mac/Linux)](#native-maclinux) or [Docker](#docker).

### Native (Mac/Linux)

#### Prerequisites

- [Ruby **(~> 2.3)**](https://www.ruby-lang.org/en/downloads/)
- [Bundler **(~> 1.15)**](https://bundler.io/)
- [Terraform **(~> 0.11.7)**](https://www.terraform.io/downloads.html)
- [Golang **(~> 1.10.3)**](https://golang.org/dl/)

#### Quick Run

We provide simple script to quickly set up module development environment:

```sh
$ curl -sSL https://raw.githubusercontent.com/Azure/terramodtest/master/tool/env_setup.sh | sudo bash
```

Then simply run it in local shell:

```sh
$ cd $GOPATH/src/{directory_name}/
$ bundle install
$ rake build
$ rake e2e
```

### Docker

We provide a Dockerfile to build a new image based `FROM` the `microsoft/terraform-test` Docker hub image which adds additional tools / packages specific for this module (see Custom Image section).  Alternatively use only the `microsoft/terraform-test` Docker hub image [by using these instructions](https://github.com/Azure/terraform-test).

#### Prerequisites

- [Docker](https://www.docker.com/community-edition#/download)

#### Custom Image

This builds the custom image:

```sh
$ docker build --build-arg BUILD_ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID --build-arg BUILD_ARM_CLIENT_ID=$ARM_CLIENT_ID --build-arg BUILD_ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET --build-arg BUILD_ARM_TENANT_ID=$ARM_TENANT_ID -t azure-vmss-cloudinit .
```

This runs the build and unit tests:

```sh
$ docker run --rm azure-vmss-cloudinit /bin/bash -c "bundle install && rake build"
```

This runs the end to end tests:

```sh
$ docker run --rm azure-vmss-cloudinit /bin/bash -c "bundle install && rake e2e"
```

This runs the full tests:

```sh
$ docker run --rm azure-vmss-cloudinit /bin/bash -c "bundle install && rake full"
```

## Authors

Originally created by [David Tesar](http://github.com/dtzar)

## License

[MIT](LICENSE)
