# Interpret namespace and network name based on user name
locals {
  namespace = "arc-llm-ns"
  network_name = "arc-llm-ns/default"
}

data "harvester_image" "img" {
  display_name = var.img_display_name
  namespace    = "arc-llm-ns"
}

data "harvester_ssh_key" "mysshkey" {
  name      = var.keyname
  namespace = local.namespace
}

resource "random_id" "secret" {
  byte_length = 5
}

resource "harvester_cloudinit_secret" "cloud-config" {
  name      = "cloud-config-${random_id.secret.hex}"
  namespace = local.namespace

  user_data = templatefile("cloud-init.tmpl.yml", {
      public_key_openssh = data.harvester_ssh_key.mysshkey.public_key
    })
}

resource "harvester_virtualmachine" "vm" {
  
  count = var.vm_count

  name                 = "${var.username}-inference-${format("%02d", count.index + 1)}-${random_id.secret.hex}"
  namespace            = local.namespace
  restart_after_update = true

  description = "Base VM"

  cpu    = 8
  memory = "128Gi"

  cpu_model = "host-passthrough"
#  reserved_memory = "64Gi" # 16Gi per card for multiple large cards
  efi         = true
  secure_boot = true

  run_strategy    = "RerunOnFailure"
  hostname        = "${var.username}-inference-${format("%02d", count.index + 1)}-${random_id.secret.hex}"
  reserved_memory = "100Mi"
  machine_type    = "q35"

  network_interface {
    name           = "nic-1"
    wait_for_lease = true
    type           = "bridge"
    network_name   = local.network_name
  }

  disk {
    name       = "rootdisk"
    type       = "disk"
    size       = "128Gi"
    bus        = "virtio"
    boot_order = 1

    image       = data.harvester_image.img.id
    auto_delete = true
  }

  cloudinit {
    user_data_secret_name = harvester_cloudinit_secret.cloud-config.name
  }

  tags = {
    condenser_ingress_isEnabled = true
    condenser_ingress_endpt_hostname = "inf${format("%02d", count.index + 1)}"
    condenser_ingress_endpt_port = 5555
    condenser_ingress_endpt_protocol = "https"
    condenser_ingress_endpt_nginx_proxy-send-timeout = 600
    condenser_ingress_endpt_nginx_proxy-read-timeout = 600
    condenser_ingress_endpt_nginx_proxy-http-version = "1.1"
  }

  timeouts {
    create = "20m"
    update = "20m"
    delete = "20m"
  }

}
