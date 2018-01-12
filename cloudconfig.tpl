#cloud-config
packages:
 - httpd
 - samba-client
 - samba-common
 - cifs-utils
package_upgrade: true
bootcmd:
 - echo test | sudo dd of=/etc/testfile &> /dev/null