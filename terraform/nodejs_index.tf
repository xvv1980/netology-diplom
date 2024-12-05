resource "local_file" "nodejs_index" {
  content  = templatefile("${path.module}/template/index.tftpl", {
    runners = yandex_compute_instance.runner
  })
  filename = "files/index.js"

  provisioner "local-exec" {
    command = "zip files/func files/index.js files/package.json"
  }
}
