resource "local_file" "hosts_cfg_kubespray" {
  content  = templatefile("${path.module}/template/hosts.tftpl", {
    workers = yandex_compute_instance.worker
    masters = yandex_compute_instance.master
  })
  filename = "../kubespray/inventory/xvv1980-diplom/hosts.yaml"
}
