variable "os_image_worker" {
  type    = string
  default = "ubuntu-2004-lts"
}

data "yandex_compute_image" "ubuntu-worker" {
  family = var.os_image_worker
}

variable "worker_count" {
  type    = number
  default = 2
}

variable "worker_resources" {
  type = object({
    cpu         = number
    ram         = number
    disk        = number
    core_fraction = number
    platform_id = string
  })
  default = {
    cpu         = 2
    ram         = 4
    disk        = 10
    core_fraction = 5
    platform_id = "standard-v1"
  }
}

resource "yandex_compute_instance" "worker" {
  depends_on = [yandex_compute_instance.master]
  count      = var.worker_count
  allow_stopping_for_update = true
  name          = "worker-${count.index + 1}"
  platform_id   = var.worker_resources.platform_id
  zone = var.zone_b
  resources {
    cores         = var.worker_resources.cpu
    memory        = var.worker_resources.ram
    core_fraction = var.worker_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-worker.image_id
      size     = var.worker_resources.disk
    }
  }

  metadata = {
    serial-port-enable = "1"
    user-data = "${file("${path.module}/cloud-init/kuber-meta.yaml")}"
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.diplom-subnet-a.id
    nat                = true
  }

  scheduling_policy {
    preemptible = true
  }
}
