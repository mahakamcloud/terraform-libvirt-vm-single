provider "libvirt" {
  uri = "qemu+tcp://${var.libvirt_host}/system"
}
