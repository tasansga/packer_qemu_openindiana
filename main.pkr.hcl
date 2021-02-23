variable "iso" {
  type = string
  default = "http://dlc.openindiana.org/isos/hipster/20201031/OI-hipster-minimal-20201031.iso"
}

variable "iso_checksum" {
  type    = string
  default = "114873598f048270603d431fdb1577db770a4d951f8a844f786edf1b5538e456"
}

variable "disk_size" {
  type    = string
  default = "10000M"
}

variable "system_name" {
  type    = string
  default = "openindiana"
}

variable "ssh_username" {
  type    = string
  default = "openindiana"
}

variable "ssh_authorized_key" {
  type    = string
  default = "my_authorized_key"
}

locals {
  // Temporary password, we'll enable key-only SSH auth later.
  ssh_password = uuidv4()
}

source "qemu" "openindiana" {
  iso_url          = var.iso
  iso_checksum     = var.iso_checksum
  disk_size        = var.disk_size
  memory           = 2048
  format           = "qcow2"
  accelerator      = "kvm"
  ssh_username     = var.ssh_username
  ssh_password     = local.ssh_password
  ssh_wait_timeout = "10m"
  shutdown_command = "sudo poweroff"
  boot_wait        = "2s"
  headless         = true
  net_device       = "virtio-net"
  disk_interface   = "virtio"
  http_port_min    = 10082
  http_port_max    = 10089
  host_port_min    = 2222
  host_port_max    = 2229
  http_directory   = "http"
  boot_command = [
    "<wait>",
    "<spacebar>",
    "<wait10>",
    "1",
    "<wait30>",
    "<enter>",
    "<wait5>",
    "<enter>",
    "<wait20>",
    "1",
    "<enter>",
    "<wait10>",
    "<f2>",
    "<f2>",
    "<right>",
    "<enter>",
    "<f2>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    var.system_name,
    "<down>",
    "<f2>",
    "<f2>",
    "<f2>",
    local.ssh_password,
    "<down>",
    local.ssh_password,
    "<down>",
    var.ssh_username,
    "<down>",
    var.ssh_username,
    "<down>",
    local.ssh_password,
    "<down>",
    local.ssh_password,
    "<f2>",
    "<f2>",
    "<wait5m>",
    "<f8>",
    "<wait2m>",
    var.ssh_username,
    "<enter>",
    local.ssh_password,
    "<enter>",
    "su",
    "<enter>",
    local.ssh_password,
    "<enter>",
    "pkg install sudo",
    "<enter>",
    "<wait2m>",
    "echo '${var.ssh_username} ALL=(ALL) NOPASSWD:ALL' >> '/etc/sudoers.d/${var.ssh_username}-nopasswd-all'",
    "<enter>",
    "<wait>"
  ]
  output_directory = "artifacts"
}

build {
  sources = [
    "source.qemu.openindiana"
  ]

  provisioner "file"{
    source = "id_rsa.pub"
    destination = "/tmp/"
  }

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    environment_vars = [
      "USERNAME=${var.ssh_username}",
    ]
    scripts = [
      "init.sh"
    ]
  }
}
