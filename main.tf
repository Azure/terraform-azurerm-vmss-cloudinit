provider "azurerm" {
  version = "~> 1.0"
}

provider "template" {
  version = "~> 1.0"
}

module "os" {
  source       = "./os"
  vm_os_simple = "${var.vm_os_simple}"
}

resource "azurerm_resource_group" "vmss" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
  tags     = "${var.tags}"
}

data "template_file" "cloudconfig" {
  template = "${file(var.cloudconfig_template_file)}"
  vars     = "${var.cloudconfig_template_vars}"
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.cloudconfig.rendered}"
  }
}

resource "azurerm_virtual_machine_scale_set" "vm-linux" {
  count               = "${var.nb_instance}"
  name                = "${var.vmscaleset_name}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.vmss.name}"
  upgrade_policy_mode = "Manual"
  tags                = "${var.tags}"

  sku {
    name     = "${var.vm_size}"
    tier     = "Standard"
    capacity = "${var.nb_instance}"
  }

  storage_profile_image_reference {
    id        = "${var.vm_os_id}"
    publisher = "${coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher)}"
    offer     = "${coalesce(var.vm_os_offer, module.os.calculated_value_os_offer)}"
    sku       = "${coalesce(var.vm_os_sku, module.os.calculated_value_os_sku)}"
    version   = "${var.vm_os_version}"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "${var.managed_disk_type}"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = "${var.data_disk_size}"
  }

  os_profile {
    computer_name_prefix = "${var.computer_name_prefix}"
    admin_username       = "${var.admin_username}"
    admin_password       = "${var.admin_password}"
    custom_data          = "${data.template_cloudinit_config.config.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${file("${var.ssh_key}")}"
    }
  }

  network_profile {
    name    = "${var.network_profile}"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = "${var.vnet_subnet_id}"
      primary                                = true
      load_balancer_backend_address_pool_ids = ["${var.load_balancer_backend_address_pool_ids}"]
    }
  }
}
