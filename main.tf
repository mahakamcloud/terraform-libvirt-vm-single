resource "libvirt_volume" "main" {
  name   = "${var.instance_name}"
  pool   = "${var.pool_name}"
  source = "${var.source_path}"
  format = "${var.disk_format}"
}

resource "libvirt_volume" "secondary" {
  name   = "${var.instance_name}-secondary"
  size   = "${var.disk_two_size_gb * 1024 * 1024 * 1024 }"
}

resource "libvirt_cloudinit_disk" "vm_init" {
  name  = "${var.instance_name}-init.iso"

  user_data = "${var.user_data}"
}

resource "libvirt_domain" "vm_domain" {
  name      = "${var.instance_name}"
  memory    = "${var.memory_size}"
  vcpu      = "${var.num_cpu}"
  autostart = "${var.autostart}"

  cloudinit = "${libvirt_cloudinit_disk.vm_init.id}"

  network_interface {
    network_name   = "${var.network_name}"
    hostname       = "${var.instance_name}"
    mac            = "${var.mac_address}"
    wait_for_lease = false
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = "${libvirt_volume.main.id}"
  }

  disk {
    volume_id = "${libvirt_volume.secondary.id}"
  }
}
