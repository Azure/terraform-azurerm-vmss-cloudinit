# data "template_file" "script" {
#   template = "${file("${path.module}/azfilestore.tpl")}"

#   vars {
#     storage_account = "mystorage"
#   }
# }

data "template_file" "cloudconfig" {
  template = "${file("${path.module}/cloudconfig.tpl")}"

  vars {
    storage_account = "mystorage"
  }
}

data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = true

  # Setup hello world script to be called by the cloud-config
  # part {
  #   filename     = "init.cfg"
  #   content_type = "text/part-handler"
  #   content      = "${data.template_file.script.rendered}"
  # }

  # Cloud config file
  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.cloudconfig.rendered}"
  }

  part {
    content_type = "text/x-shellscript"
    content      = "echo hello"
  }

}
