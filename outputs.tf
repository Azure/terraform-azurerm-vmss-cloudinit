output "vmss_id" {
  value = "${azurerm_virtual_machine_scale_set.vm-linux.*.id}"
}
