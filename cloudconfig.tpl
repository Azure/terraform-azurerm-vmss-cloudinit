#cloud-config
packages:
 - httpd
 - samba-client
 - samba-common
 - cifs-utils
package_upgrade: true
runcmd:
 - echo "hello world" > /tmp/${tempfile}