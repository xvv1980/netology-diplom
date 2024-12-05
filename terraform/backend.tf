terraform {
  backend "s3" {
       endpoints = {
                   s3 =       "https://storage.yandexcloud.net"
      }
    region = "ru-central1"
    key = "tf-remote-state-diplom"
    skip_region_validation = true
    skip_credentials_validation = true
    skip_requesting_account_id = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
  }
}
