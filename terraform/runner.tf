variable "os_image_runner" {
  type    = string
  default = "ubuntu-2004-lts"
}

data "yandex_compute_image" "ubuntu-runner" {
  family = var.os_image_runner
}

variable "runner_count" {
  type    = number
  default = 1
}

variable "runner_resources" {
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

resource "yandex_compute_instance" "runner" {
  depends_on = [yandex_compute_instance.master]
  count      = var.runner_count
  allow_stopping_for_update = true
  name          = "runner-${count.index + 1}"
  platform_id   = var.runner_resources.platform_id
  zone = var.zone_b
  resources {
    cores         = var.runner_resources.cpu
    memory        = var.runner_resources.ram
    core_fraction = var.runner_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-runner.image_id
      size     = var.runner_resources.disk
    }
  }


  metadata = {
    serial-port-enable = "1"
    user-data = "${file("cloud-init/runner-meta.yaml")}"
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.diplom-subnet-b.id
    nat                = true
  }

  scheduling_policy {
    preemptible = true
  }
}