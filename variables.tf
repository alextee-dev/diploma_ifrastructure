### Cloud
variable "cloud_id" {
  type        = string
  default     = "b1g6ufvpo7vkirq2qlm7"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  default     = "b1g7scrj5f0n2u2d9n3l"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "service_account_id" {
  type        = string
  default     = "ajevgpg44lkku7rrrrj1"
}

variable "network_id" {
  type        = string
  default     = "enpqjp4vbiakmsksa9u7"
}

variable "subnet_a_id" {
  type        = string
  default     = "e9bdm123jfqda6mtsqe0"
}

### VMs

variable "vm_platform" {
  type        = string
  default     = "standard-v2"
  description = "VM Platform Id"
}

variable "vms_resources" {
  type = map(object({
    name = string
    cores = number
    memory = number
    core_fraction = number
    disk_size = number
    disk_type = string
  }))  
  default = {
    "control" = {
      name = "k8s-control-node"
      cores = 2
      memory = 4
      core_fraction = 20
      disk_size = 10
      disk_type = "network-hdd"
    },
    "worker" = {
      name = "k8s-worker-node-"
      cores = 2
      memory = 4
      core_fraction = 50
      disk_size = 10
      disk_type = "network-hdd"
    }
    
  }
}

variable "vms_ssh_root_key" {
  type        = string
  default     = "/root/.ssh/yc-ansible.pub"
}

variable "vm_os_family" {
  type        = string
  default     = "ubuntu-2204-lts-oslogin"
  description = "OS Family"
}

variable "vm_group_name" {
  type        = string
  default     = "k8s-workers"
}

variable "inventory_path" {
  type        = string
  default     = "/home/atimofeev/Diploma/ansible/kubespray/inventory/mycluster/inventory.ini"
}

### Load Balancer vars

variable "balancer" {
  type = map(object({
    name = string
    target_group_name = string
    listener_name = string
    router_name = string
    virtual_host_name = string
  }))  
  default = {
    "alb" = {
      name = "application-load-balancer-1"
      target_group_name = "target-group"
      listener_name = "http-listener"
      router_name = "http-router"
      virtual_host_name = "virtual-host"
    }
  }
}

variable "backend" {
  type = map(object({
    route_name = string
    backend_group = string
    http_backend = string
    http_backend_port = number
    http_path = string
    prefix_rewrite = string
  }))  
  default = {
    "app" = {
      route_name = "test-app"
      backend_group = "backend-test-app"
      http_backend = "http-backend-app"
      http_backend_port = 30000
      http_path = "/app"
      prefix_rewrite = "/"
    },
    "grafana" = {
      route_name = "grafana"
      backend_group = "backend-grafana"
      http_backend = "http-backend-grafana"
      http_backend_port = 30001
      http_path = "/"
      prefix_rewrite = "/login"
    }
  }
}