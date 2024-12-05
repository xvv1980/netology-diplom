# Создаем сервисный аккаунт для управления бакетом
resource "yandex_iam_service_account" "sa-bucket" {
  folder_id = var.folder_id
  name      = var.account_name
}

# Настраиваем роль для сервисного аккаунта
resource "yandex_resourcemanager_folder_iam_member" "storage_sa_editor" {
  folder_id = var.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa-bucket.id}"
}

# Создаем статический ключ доступа для сервисного аккаунта
resource "yandex_iam_service_account_static_access_key" "terraform_service_account_key" {
  service_account_id = yandex_iam_service_account.sa-bucket.id
}

# Используем ключ доступа для создания бакета
resource "yandex_storage_bucket" "terraform-bucket" {
  access_key = yandex_iam_service_account_static_access_key.terraform_service_account_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.terraform_service_account_key.secret_key

  bucket     = var.bucket_name

  anonymous_access_flags {
    read        = false
    list        = false
    config_read = false
  }

  force_destroy = true



  provisioner "local-exec" {
    command = "echo export AWS_ACCESS_KEY=${yandex_iam_service_account_static_access_key.terraform_service_account_key.access_key} > ../files/aws_credential"
  }


  provisioner "local-exec" {
    command = "echo export AWS_SECRET_KEY=${yandex_iam_service_account_static_access_key.terraform_service_account_key.secret_key} >> ../files/aws_credential"
  }
}
