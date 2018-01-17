#cloud-config
package_upgrade: true
runcmd:
 - echo "Created by Azure terraform-vmss-cloudinit module." | sudo dd of=/tmp/terraformtest &> /dev/null