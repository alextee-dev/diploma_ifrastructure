data template_file "cloudinit" {
  template = file("./cloud-init.yml")

  vars = {
    ssh_public_key     = file(var.vms_ssh_root_key)
  }
}

data "yandex_compute_image" "ubuntu" {
  family = "${var.vm_os_family}"
}

### Create Controle node

resource "yandex_compute_instance" "control-node" {
  name        = var.vms_resources.control.name
  platform_id = var.vm_platform
  zone        = var.default_zone

  resources {
    core_fraction = var.vms_resources.control.core_fraction
    cores         = var.vms_resources.control.cores
    memory        = var.vms_resources.control.memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id          = var.subnet_a_id
    nat                = true
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "${local.ubukey}"
    user-data          = data.template_file.cloudinit.rendered
  }
}

### Create Worker nodes

resource "yandex_compute_instance_group" "worker-nodes" {
  name                = var.vm_group_name
  folder_id           = var.folder_id
  service_account_id  = var.service_account_id
  deletion_protection = false
  instance_template {
    platform_id = var.vm_platform
    resources {
      core_fraction = var.vms_resources.worker.core_fraction
      memory = var.vms_resources.worker.memory
      cores  = var.vms_resources.worker.cores
    }
    boot_disk {
      initialize_params {
        image_id = data.yandex_compute_image.ubuntu.image_id
        size     = var.vms_resources.worker.disk_size
        type     = var.vms_resources.worker.disk_type
      }
    }
    network_interface {
      network_id = var.network_id
      subnet_ids = ["${var.subnet_a_id}"]
      nat = true
    }
    metadata = {
        ssh-keys           = "${local.ubukey}"
        user-data          = data.template_file.cloudinit.rendered
    }
  }

  scale_policy {
    fixed_scale {
      size = 2
    }
  }

  allocation_policy {
    zones = ["${var.default_zone}"]
  }

  deploy_policy {
    max_unavailable = 1
    max_creating    = 1
    max_expansion   = 1
    max_deleting    = 1
  }

### Application Load Balancer

  application_load_balancer {
    target_group_name        = var.balancer.alb.target_group_name
  }
}

### Application Load Balancer

# Создание Application Load Balancer
resource "yandex_alb_load_balancer" "alb" {
  name               = var.balancer.alb.name
  network_id         = var.network_id

  allocation_policy {
    location {
      zone_id   = var.default_zone
      subnet_id = var.subnet_a_id
    }
  }

  listener {
    name = var.balancer.alb.listener_name
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.router.id
      }
    }
  }
}

# # Создание HTTP роутера
resource "yandex_alb_http_router" "router" {
  name = var.balancer.alb.router_name
}

# # Создание виртуального хоста
resource "yandex_alb_virtual_host" "virtual-host" {
  name           = var.balancer.alb.virtual_host_name
  http_router_id = yandex_alb_http_router.router.id

  route {
    name = var.backend.app.route_name
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.test_app.id
        prefix_rewrite = var.backend.app.prefix_rewrite
      }
      http_match {
        path {
          exact = var.backend.app.http_path
        }
      }
    }
  }
  route {
    name = var.backend.grafana.route_name
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.grafana.id
      }
    http_match {
      path {
        prefix = var.backend.grafana.http_path
        }
      }
    }
  }
}

# Создание группы бэкендов
resource "yandex_alb_backend_group" "test_app" {
  name = var.backend.app.backend_group

  http_backend {
    name            = var.backend.app.http_backend
    weight          = 1
    port            = var.backend.app.http_backend_port
    target_group_ids = [yandex_compute_instance_group.worker-nodes.application_load_balancer.0.target_group_id]
  }
}

resource "yandex_alb_backend_group" "grafana" {
  name = var.backend.grafana.backend_group

  http_backend {
    name            = var.backend.grafana.http_backend
    weight          = 1
    port            = var.backend.grafana.http_backend_port
    target_group_ids = [yandex_compute_instance_group.worker-nodes.application_load_balancer.0.target_group_id]
  }
}

### Create inventory file

data "template_file" "inventory" {
  template = file("inventory.tpl")

  vars = {
    control_nat_ip = yandex_compute_instance.control-node.network_interface[0].nat_ip_address
    control_int_ip = yandex_compute_instance.control-node.network_interface[0].ip_address
    worker0_nat_ip = yandex_compute_instance_group.worker-nodes.instances[0].network_interface[0].nat_ip_address
    worker0_int_ip = yandex_compute_instance_group.worker-nodes.instances[0].network_interface[0].ip_address
    worker1_nat_ip = yandex_compute_instance_group.worker-nodes.instances[1].network_interface[0].nat_ip_address
    worker1_int_ip = yandex_compute_instance_group.worker-nodes.instances[1].network_interface[0].ip_address
  }
}

resource "local_file" "inventory" {
  filename = var.inventory_path
  content  = data.template_file.inventory.rendered
}