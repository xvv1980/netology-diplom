# Создаем группу балансировщика

resource "yandex_lb_target_group" "bg" {
  name       = "balancer-group"
  depends_on = [yandex_compute_instance.master]
  dynamic "target" {
    for_each = yandex_compute_instance.worker
    content {
      subnet_id = target.value.network_interface.0.subnet_id
      address   = target.value.network_interface.0.ip_address
    }
  }
}

# Создаем балансировщик grafana
resource "yandex_lb_network_load_balancer" "nlb-ingress" {
  name = "grafana"
  listener {
    name        = "grafana-listener"
    port        = 80
    target_port = 30050
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  attached_target_group {
    target_group_id = yandex_lb_target_group.bg.id
    healthcheck {
      name = "healthcheck"
      tcp_options {
        port = 30050
      }
    }
  }
  depends_on = [yandex_lb_target_group.bg]
}
