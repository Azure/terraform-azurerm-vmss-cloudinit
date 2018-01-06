variable "vm_os_simple" {
  default = ""
}

# Definition of the standard OS with "SimpleName" = "publisher,offer,sku"
variable "standard_os" {
  default = {
    "UbuntuServer"   = "Canonical,UbuntuServer,16.04-LTS"
    "UbuntuServer14" = "Canonical,UbuntuServer,14.04.5-LTS"
    "RHEL"           = "RedHat,RHEL,7-RAW-CI"
    "CentOS"         = "OpenLogic,CentOS,7-CI"
    "CoreOS"         = "CoreOS,CoreOS,Stable"
  }
}
