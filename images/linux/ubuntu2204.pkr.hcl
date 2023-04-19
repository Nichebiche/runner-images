variable "allowed_inbound_ip_addresses" {
  type    = list(string)
  default = []
}

variable "azure_tags" {
  type    = map(string)
  default = {}
}

variable "build_resource_group_name" {
  type    = string
  default = "${env("BUILD_RESOURCE_GROUP_NAME")}"
}

variable "capture_name_prefix" {
  type    = string
  default = "packer"
}

variable "client_id" {
  type    = string
  default = "${env("ARM_CLIENT_ID")}"
}

variable "client_secret" {
  type      = string
  default   = "${env("ARM_CLIENT_SECRET")}"
  sensitive = true
}

variable "client_cert_path" {
  type      = string
  default   = "${env("ARM_CLIENT_CERT_PATH")}"
}

variable "commit_url" {
  type      = string
  default   = ""
}

variable "dockerhub_login" {
  type    = string
  default = "${env("DOCKERHUB_LOGIN")}"
}

variable "dockerhub_password" {
  type    = string
  default = "${env("DOCKERHUB_PASSWORD")}"
}

variable "helper_script_folder" {
  type    = string
  default = "/imagegeneration/helpers"
}

variable "image_folder" {
  type    = string
  default = "/imagegeneration"
}

variable "image_os" {
  type    = string
  default = "ubuntu22"
}

variable "image_version" {
  type    = string
  default = "dev"
}

variable "imagedata_file" {
  type    = string
  default = "/imagegeneration/imagedata.json"
}

variable "installer_script_folder" {
  type    = string
  default = "/imagegeneration/installers"
}

variable "install_password" {
  type  = string
  default = ""
}

variable "location" {
  type    = string
  default = "${env("ARM_RESOURCE_LOCATION")}"
}

variable "private_virtual_network_with_public_ip" {
  type    = bool
  default = false
}

variable "resource_group" {
  type    = string
  default = "${env("ARM_RESOURCE_GROUP")}"
}

variable "run_validation_diskspace" {
  type    = bool
  default = false
}

variable "storage_account" {
  type    = string
  default = "${env("ARM_STORAGE_ACCOUNT")}"
}

variable "subscription_id" {
  type    = string
  default = "${env("ARM_SUBSCRIPTION_ID")}"
}

variable "temp_resource_group_name" {
  type    = string
  default = "${env("TEMP_RESOURCE_GROUP_NAME")}"
}

variable "tenant_id" {
  type    = string
  default = "${env("ARM_TENANT_ID")}"
}

variable "virtual_network_name" {
  type    = string
  default = "${env("VNET_NAME")}"
}

variable "virtual_network_resource_group_name" {
  type    = string
  default = "${env("VNET_RESOURCE_GROUP")}"
}

variable "virtual_network_subnet_name" {
  type    = string
  default = "${env("VNET_SUBNET")}"
}

variable "vm_size" {
  type    = string
  default = "Standard_D4s_v4"
}

source "azure-arm" "build_vhd" {
  allowed_inbound_ip_addresses           = "${var.allowed_inbound_ip_addresses}"
  build_resource_group_name              = "${var.build_resource_group_name}"
  capture_container_name                 = "images"
  capture_name_prefix                    = "${var.capture_name_prefix}"
  client_id                              = "${var.client_id}"
  client_secret                          = "${var.client_secret}"
  client_cert_path                       = "${var.client_cert_path}"
  image_offer                            = "0001-com-ubuntu-server-jammy"
  image_publisher                        = "canonical"
  image_sku                              = "22_04-lts"
  location                               = "${var.location}"
  os_disk_size_gb                        = "86"
  os_type                                = "Linux"
  private_virtual_network_with_public_ip = "${var.private_virtual_network_with_public_ip}"
  resource_group_name                    = "${var.resource_group}"
  storage_account                        = "${var.storage_account}"
  subscription_id                        = "${var.subscription_id}"
  temp_resource_group_name               = "${var.temp_resource_group_name}"
  tenant_id                              = "${var.tenant_id}"
  virtual_network_name                   = "${var.virtual_network_name}"
  virtual_network_resource_group_name    = "${var.virtual_network_resource_group_name}"
  virtual_network_subnet_name            = "${var.virtual_network_subnet_name}"
  vm_size                                = "${var.vm_size}"

  dynamic "azure_tag" {
    for_each = var.azure_tags
    content {
      name = azure_tag.key
      value = azure_tag.value
    }
  }
}

build {
  sources = ["source.azure-arm.build_vhd"]
}

  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline          = ["mkdir ${var.image_folder}", "chmod 777 ${var.image_folder}"]
  }

  provisioner "file" {
    destination = "${var.helper_script_folder}"
    source      = "${path.root}/scripts/helpers"
  }

  provisioner "file" {
    destination = "${var.installer_script_folder}"
    source      = "${path.root}/scripts/installers"
  }

  provisioner "file" {
    destination = "${var.image_folder}"
    source      = "${path.root}/post-generation"
  }

  provisioner "file" {
    destination = "${var.image_folder}"
    source      = "${path.root}/scripts/tests"
  }

  provisioner "file" {
    destination = "${var.image_folder}"
    source      = "${path.root}/scripts/SoftwareReport"
  }

  provisioner "file" {
    destination = "${var.image_folder}/SoftwareReport/"
    source      = "${path.root}/../../helpers/software-report-base"
  }

  provisioner "file" {
    destination = "${var.installer_script_folder}/toolset.json"
    source      = "${path.root}/toolsets/toolset-2204.json"
  }

  provisioner "shell" {
    execute_command   = "/bin/sh -c '{{ .Vars }} {{ .Path }}'"
    expect_disconnect = true
    scripts           = ["${path.root}/scripts/base/reboot.sh"]
  }

  provisioner "shell" {
    execute_command     = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    pause_before        = "1m0s"
    scripts             = ["${path.root}/scripts/installers/cleanup.sh"]
    start_retry_timeout = "10m"
  }

  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline          = ["sleep 30", "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"]
  }