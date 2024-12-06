## Дипломный практикум в Yandex.Cloud
----
#### Выполнил 
#### студент группы DEVOPS00000 
#### Храмов Василий Владимирович
----
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
     * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
        * [Демонстрация работы по развертыванию инфраструктуры](#демонстрация-работы-по-развертыванию-инфраструктуры)
        * [Демонстрация работы GITHUB workflows](#демонстрация-работы-github-workflows)
     * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
     * [Создание тестового приложения](#создание-тестового-приложения)
     * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры
Особенности выполнения:

В связи с ограничениями в бюджете купона инфраструктура проекта будет содержать минимальные конфигурации, достаточные для демонстрации основных целей проекта. 

Так все vm будут c 2 ядрами, 4Гб ОЗУ, 10Гб диска, 5% использования процессора.

Для выполнения поставленных целей, решено использовать 1 мастер-ноду, 2 worker-ноды, 1 runner-ноду(для запуска gitlab-runner)

Для экономии ресурсов, runner-нода будет выключена. Запуск этой ноды будет происходить автоматически при внесении изменений в исходники приложения.

Таким образом инфраструктура будет состоять из:

| Объект  |   Кол-во |
|----------|---------|
| network  |    1    |
| subnet   |     2   |
|   vm     |     4   |
|   cpu    |     8         |
| RAM      |   16 Гб       |
| HDD | 40 Гб |
| Object Storage| 1 bucket |
| Cloud function| 1 |

Для запуска terraform манифестов создан сервисный аакаунт с ограниченным количеством прав, достаточных для реализации поставленных целей.

![изображение](https://github.com/user-attachments/assets/0101cc8a-a5db-4b0e-85a2-0e157e440991)


>[!NOTE]
>Состояние Terraform описывает текущую развернутую инфраструктуру и хранится в файлах с расширением .tfstate. Файл состояния создается после развертывания   инфраструктуры и может быть сразу загружен в Object Storage. Загруженный файл состояния будет обновляться после изменений созданной инфраструктуры. Для этого будем  использовать S3 BUCKET созданый в облаке YandexCloud.

Структура каталога terraform:
[Манифесты terraform для инфраструктуры](terraform/)
- terraform(***root***)
  - cloud-init(***каталог для cloud-config файлов***)
  - files(***каталог для дополнительных файлов***)
  - s3-bucket(***terraform каталог для создания object storage***)
  - template(***каталог для jinja шаблонов***)
> [!TIP]
> В каталог files хранятся вспомогательные файлы для создания yandex cloud function, а также туда будет записан
> файл с командами экспорта переменных окружения AWS_ACCESS_KEY и AWS_SECRET_KEY для доступа к bucket для чтения файла состояния.

Возможность работы с вынесенным файлом состояния включается в [backend.tf](terraform/backend.tf)

Инфраструктура будет работать в двух подсетях в различных зонах доступности. [main.tf](terraform/main.tf)

#### Демонстрация работы по развертыванию инфраструктуры

1. Начинаем с создания OBJECT STORAGE для хранения terraform состояния инфраструктуры:
    -  Входим в каталог [s3-bucket](terraform/s3-bucket)
    -  ```terraform validate; terraform plan```
    -  ```terraform apply```
![изображение](https://github.com/user-attachments/assets/9f9c38a4-a392-4b82-8eac-617bb9643c5f)

Создан сервисный аккаунт для работы с хранилищем

![изображение](https://github.com/user-attachments/assets/b3ca8a51-6a33-4e94-897e-6594a8e4e3b9)


Создан бакет

![изображение](https://github.com/user-attachments/assets/dea860fd-535d-4c56-ba45-2bec113e8077)

2. Создание основной инфраструктуры:
   - Переходим в корневой каталог terraform
   - Проверяем и экспортируем переменные окружения AWS_*_KEY
 ![изображение](https://github.com/user-attachments/assets/c8f75ade-d8e3-4d56-beb2-e9b1fc519317)

   -  ```terraform validate; terraform plan```
   -  ```terraform apply```
   - окончательный фрагмент вывода
   ![изображение](https://github.com/user-attachments/assets/d4c35e17-0330-48bc-bc43-64376168ab62)


Созданы виртуальные машины

![изображение](https://github.com/user-attachments/assets/09503926-3e02-4508-ac7a-63b776073cda)

Сохранено состояние инфраструктуры

![изображение](https://github.com/user-attachments/assets/5ccd119f-63c7-4554-aee5-8b7201db2098)


#### Демонстрация работы GITHUB workflows

1. Начинаем с создания GITHUB ACTION workfkow. [terraform workflows](.github/workflows/terraform.yaml)

   Отслеживать будем изменения в ветке main в файлах каталога terraform:
   
```
 on:
  push:
    branches:
      - main
    paths:
      - 'terraform/**'
```

   В переменых GITHUB репозитория описываем секреты:

![изображение](https://github.com/user-attachments/assets/37c89a44-638e-4de3-aaee-d2a3b8851030)


  Пробрасывааем в окружение внутри workflows:

```

jobs:
  terraform:
    name: 'Terraform'
    runs-on: ubuntu-latest
    env:
       TOKEN: ${{ secrets.YC_TOKEN }}
       CLOUD_ID: ${{ secrets.YC_CLOUD_ID }}
       FOLDER_ID: ${{ secrets.YC_FOLDER_ID }}
       AWS_ACCESS_KEY: ${{ secrets.AWS_ACCESS_KEY }}
       AWS_SECRET_KEY: ${{ secrets.AWS_SECRET_KEY }}
``` 

  Будут выполнены основые terraform команды: init, plan, apply. Команда plan подготовит инфратсруктуру в файл tfplan и передаст его на вход команды apply.

  ```
 - name: Terraform Plan
      run: |
        terraform -chdir=./terraform plan -input=false -out=tfplan \
        -var="token=${{ secrets.YC_TOKEN }}" \
        -var="cloud_id=${{ secrets.YC_CLOUD_ID }}" \
        -var="folder_id=${{ secrets.YC_FOLDER_ID }}" \

    - name: Terraform Apply (Automatic Trigger)
      if: github.event_name == 'push' && github.ref == 'refs/heads/main'
      run: terraform -chdir=./terraform apply -input=false tfplan
   ```

   2. Выполняем команду terraform destroy.

  ![изображение](https://github.com/user-attachments/assets/d33aa9e2-651e-4d38-bd88-32dbffc5320f)

   3. Проверяем что нет созданных вирт.машин
  
  ![изображение](https://github.com/user-attachments/assets/480cce9e-8df7-449c-bbc9-691e0adebf92)


   4.Вносим исправления в манифест из каталога terraform. 

   ![изображение](https://github.com/user-attachments/assets/676c3c06-47e2-42ca-96c3-0557a0c2ae67)

   
   В результате сработает workflows и развернет инфраструктуру.
 ![изображение](https://github.com/user-attachments/assets/c390c252-54a6-41ab-8fba-18ab1a7e20ad)

   5. Проверяем наличие созданных вирт. машин
 ![изображение](https://github.com/user-attachments/assets/702c6405-bb11-4d30-a742-55145110f328)

### Создание Kubernetes кластера

 Создание kubernetes кластера проведем с использование Kubespray. 

 `git clone https://github.com/kubernetes-sigs/kubespray.git

  Для моего ALT LInux подошла ветка release-2.24
  
  Для разворачивания кластера с помощью kubespray необходим файл инвентаризации, который был подготовлен на этапе раветывания инфаструктуры с помошью шаблона.
  Данный шаблон применен в манифесте [hosts.tftpl](terraform/template/hosts.tftpl)
  
```

  all:
  hosts:%{ for idx, master in masters }
    master:
      ansible_host: ${master.network_interface[0].nat_ip_address}
      ip: ${master.network_interface[0].ip_address}
      access_ip: ${master.network_interface[0].ip_address}%{ endfor }
  %{ for idx, worker in workers }
    worker-${idx + 1}:
      ansible_host: ${worker.network_interface[0].nat_ip_address}
      ip: ${worker.network_interface[0].ip_address}
      access_ip: ${worker.network_interface[0].ip_address}%{ endfor }
  children:
    kube_control_plane:
      hosts:%{ for idx, master in masters }
        ${master.name}:%{ endfor }
    kube_node:
      hosts:%{ for idx, worker in workers }
        ${worker.name}:%{ endfor }
    etcd:
      hosts:%{ for idx, master in masters }
        ${master.name}:%{ endfor }
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
```

Данный шаблон применен в манифесте [ansible.tf](terraform/ansible.tf)

```
resource "local_file" "hosts_cfg_kubespray" {
  content  = templatefile("${path.module}/template/hosts.tftpl", {
    workers = yandex_compute_instance.worker
    masters = yandex_compute_instance.master
  })
  filename = "../kubespray/inventory/xvv1980-diplom/hosts.yaml"
}
```

Получившийся инвентарь по текущей инфраструктуре:

```

all:
  hosts:
    master:
      ansible_host: 89.169.128.255
      ip: 10.0.1.6
      access_ip: 10.0.1.6
  
    worker-1:
      ansible_host: 158.160.68.117
      ip: 10.0.2.21
      access_ip: 10.0.2.21
    worker-2:
      ansible_host: 89.169.172.48
      ip: 10.0.2.29
      access_ip: 10.0.2.29
  children:
    kube_control_plane:
      hosts:
        master:
    kube_node:
      hosts:
        worker-1:
        worker-2:
    etcd:
      hosts:
        master:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
```
 
Запускаем настройку кластера kubernetes

` ansible-playbook -i inventory/xvv1980-diplom/hosts.yaml -u ubuntu --become --become-user=root --private-key=~/.ssh/id_ed25519 -e 'ansible_ssh_common_args="-o StrictHostKeyChecking=no"' cluster.yml --flush-cache `
