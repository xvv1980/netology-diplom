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
        * [Демонстрация работы CI/CD процесса](#демонстрация-работы-CI/CD-процесса)
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
 
 1. Запускаем настройку кластера kubernetes

` ansible-playbook -i inventory/xvv1980-diplom/hosts.yaml -u ubuntu --become --become-user=root --private-key=~/.ssh/id_ed25519 -e 'ansible_ssh_common_args="-o StrictHostKeyChecking=no"' cluster.yml --flush-cache `

Вывод об окончании установки кластера:

![изображение](https://github.com/user-attachments/assets/54530b8b-4527-45b3-8de5-b0122376ce89)

 2. Настраиваем утилиту kubectl.

Переносим /etc/kubernetes/admin.conf на локальную машину и прописываем в нем ip адреса master ноды.

 3. Проверка кластера

![изображение](https://github.com/user-attachments/assets/dee429d1-1ffb-4827-8289-b0cae288e064)


### Создание тестового приложения

 1. Приложение будет состоять из статического html файла, который показывает различные картинки в зависимости от того какая версия приложения + произвольный текст определнный разработчиком.

- app
  - image1.jpg
  - image2.jpg
  - index.html
 
 2. Приложение будет упаковано в docker образ diplom. Образ будет храниться на Docker HUB ресурсе.
    
 3. Логинимся к Docker hub

    `docker login -u xvv1980`
    
 4. Собираем образ c указанием id реестра
        
    ![изображение](https://github.com/user-attachments/assets/49dee863-d67c-4c76-8b43-a079b877bbb9)


 5. Проверем наличие на локальной машине
    
    ![изображение](https://github.com/user-attachments/assets/cebc33fa-4a6e-4751-8245-f9b23c67a4f2)


 6. Загружаем в хранилище

    ![изображение](https://github.com/user-attachments/assets/10a3fda1-3c0a-488d-bc4e-0bbf4c852329)

 7. Смотрим в web интерфейсе docker hub

     ![изображение](https://github.com/user-attachments/assets/173d156d-2785-41dd-947c-ae121fcfee3a)


    
  
  ### Подготовка cистемы мониторинга и деплой приложения

  
 - Систему мониторинга будем устанавливать с помощью диспетчера пакетов для kubernetes - HELM.
  
 - Первоначальный деплой приложения проведем путем применения манифестов с помощью утилиты kubectl.

 - Для выполнения требования , которое говорит о том, что система мониторинга и тестовое приложение должны отвечать на одном порту 80, организуем связку Network Load Balancer и ingress контроллера.

   Схема маршрутизации запроса:
   
   --> ip network load balancer --> ingress-controller > ingress-app --> service-app

   http:// ip network load balancer/              <-- на тестовое приложение
   
   http:// ip network load balancer/grafana       <-- на систему мониторинга.

   В итоге будет два ingress объекта. Один будет установлен при установке helm  PROMETHEUS-GRAFANA-ALERTMANAGER, а другой для тестового приложения мы поднимем сами.
   ingress будут находиться в разных namespace-ах.


 - Будем использовать ingress контроллер nginx. Ingress-nginx установим посредством HELM.
  

 1. Устанавливаем ingress-controller NGINX, определяем заранее конкретные NodePort-ы которые поднимает контроллер. Эти порты были указаны на этапе создания network load balancer, например 30050. Вносим изменения в файл helm value для тонкой настройки приложения.

    [ingress-nginx-values.yaml](k8s-manifest/helm-values/ingress-nginx-value.yaml)
    ```
     nodePorts:
      # -- Node port allocated for the external HTTP listener. If left empty, the service controller allocates one from the configured node port range.
      http: "30050"
      # -- Node port allocated for the external HTTPS listener. If left empty, the service controller allocates one from the configured node port range.
      https: "30051"
      # -- Node port mapping for external TCP listeners. If left empty, the service controller allocates them from the configured node port range.
    ```

    ![изображение](https://github.com/user-attachments/assets/1301d168-5d0a-440e-a298-563cc6da6430)

    Проверяем сетевые настройки и установленные порты:

    ![изображение](https://github.com/user-attachments/assets/d6d36160-91e7-4fc1-82ab-69f0f330cda7)

  2. Устанавливаем систему мониторинга, сбора метрик.(PROMETHEUS-GRAFANA-ALERTMANAGER)

     Чтобы корректно работала схема с grafana нужно будет переопределить конфигурацию по умолчанию через в  [monitoring-values.yaml](k8s-manifest/helm-values/monitoring-values.yaml)

```     
     ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/rewrite-target: /$1
    nginx.ingress.kubernetes.io/use-regex: "true"

  path: /grafana/?(.*)
  hosts:
    - k8s.example.dev

grafana.ini:
  server:
    root_url: http://localhost:3000/grafana

```

   Т.е. нужно включить в helm чарт-е возможность настройки своего ingress. 
    
  ![изображение](https://github.com/user-attachments/assets/9239207c-a7f3-4ea9-9b18-23fb3b7549ad)
    

  4. Устанавливаем тестовое приложение с локальной машины для проверки деплоя в целом, в дальнейшем будем использовать только CI/CD GITLAB.

     [Deployment](cicd-gitlab-example/manifest/deploy.yaml), [Service](cicd-gitlab-example/manifest/service.yaml), [Ingress](cicd-gitlab-example/manifest/ingress.yaml)

  5. Проверем установленные приложения

Мониторинг
     ![изображение](https://github.com/user-attachments/assets/8b70b342-a93f-4be2-adcd-014c75cc35f5)

    Тестовое приложение
   ![изображение](https://github.com/user-attachments/assets/5b5f1589-985a-45d0-8488-4c6ca9e39791)

  6. Проверяем что [Network Load Balancer](terraform/lb.tf) создан на предыдущих шагах и пройдена проверка состояния

     ![изображение](https://github.com/user-attachments/assets/bbd3346a-e45d-4299-b093-66f4ce1b588c)

   
  7. Проверяем работу в браузере Grafana

   ![изображение](https://github.com/user-attachments/assets/4ef8dcfd-851b-4d28-946d-e2b91b4808fc)

  8. Проверяем работу в браузере тестового приложения(версия 1.1)

     ![изображение](https://github.com/user-attachments/assets/177de343-494f-4fdb-ba22-5e923c7acd71)



  ### Установка и настройка CI/CD

 1. Для CI/CD процессов воспользуемся системой от GITLAB. 
  Создан проект https://gitlab.com/netology7085248/diplom.git.
  
  ![изображение](https://github.com/user-attachments/assets/2e449af8-37bc-4710-8b54-26418b10760d)

  В проекте присутствуют:
- файлы приложения app/
  -  index.html и картинки
-  Dockerfile для сборки образа из предыдущих шагов
-  Манифесты для деплоя в к8s кластер manifest/

 2. Для запуска процессов CI/CD нужен запущенный и зарегистрированный GITLAB Runner.

    Для этой цели поднята отдельная ВМ runner-1. При ее создании был передан [cloud-config](terraform/cloud-init/runner-meta.yaml) в котором есть команды установки необходимого программного обеспечения и регистрации на gitlab.

    Проверяем что runner зарегистрирован.
    
    ![изображение](https://github.com/user-attachments/assets/5f978720-e700-4459-87fc-bffe3e2fe9f8)

  3. Процесс сборки будет осуществляться с использованием пакета buildah в шаге **build_image**.

     Логика заложена такая, что если при коммите указывается тег, то в docker репозиторий загрузится образ с указанным тегом, а также и с тегом latest.
     Если тега нет, то загрузится образ с тегом ввиде короткого значения коммита.

  4. Процесс развертывания будет запускаться вручную только в том случае, когда в репозитории фиксируется коммит с тегом или в ветку main.
  
  5. [GITLAB-CI](cicd-gitlab-example/.gitlab-ci.yml)
  
  ### Демонстрация работы CI/CD процесса

  1. Создаем новую ветку для разработки новой версии 1.2

     ![изображение](https://github.com/user-attachments/assets/7cf37aa9-eff0-474b-8f9f-c600d758711d)

     Так как коммит был не в основную ветку и без тега, то создался и загрузился только образ. Проверяем в репозитории docker.
     Видим что коммит и тег совпадают.

     ![изображение](https://github.com/user-attachments/assets/5cea9535-057a-4a17-b4c3-51eee65a46ef)

     Pipeline состоит из одного stage

     ![изображение](https://github.com/user-attachments/assets/24dba3c5-de44-43ec-9d64-58b4d5a4c265)

   3. Сливаем ветку в основную, затем присваиваем тег.

   Видим что доступен следующий шаг - deploy.
      
   ![изображение](https://github.com/user-attachments/assets/1534565d-f225-43a9-b3b4-d02b3d1d5432)

   Вручную запускаем deploy.

   ![изображение](https://github.com/user-attachments/assets/e7244d89-0f8b-49e7-90f6-6f583d5850ff)

   В итоге видим страницу с новой версией

   ![изображение](https://github.com/user-attachments/assets/fb6470ad-a00e-487d-92d9-8e76ea71aac3)




      




  

  


    





