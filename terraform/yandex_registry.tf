resource "yandex_container_registry" "cr-yandex" {
  name = "xvv1980"
  folder_id = var.folder_id
  labels = {
    my-label = "diplom"
  }
}
