resource "yandex_function" "test-function" {
    name               = "webhook-func-gitlab"
    description        = "gitlab"
    user_hash          = "first-function"
    runtime            = "nodejs18"
    entrypoint         = "index.handler"
    memory             = "128"
    execution_timeout  = "10"
#    service_account_id = 
    tags               = ["my_tag"]
    content {
        zip_filename = "files/func.zip"
    }

   depends_on = [local_file.nodejs_index]

}
