output "ControlNode_NAT_IP" {
  value = yandex_compute_instance.control-node.network_interface[0].nat_ip_address
}

output "ControlNode_Int_IP" {
  value = yandex_compute_instance.control-node.network_interface[0].ip_address
}

output "WorkerNode-0_NAT_IP" {
  value = yandex_compute_instance_group.worker-nodes.instances[0].network_interface[0].nat_ip_address
}

output "WorkerNode-0_Int_IP" {
  value = yandex_compute_instance_group.worker-nodes.instances[0].network_interface[0].ip_address
}

output "WorkerNode-1_NAT_IP" {
  value = yandex_compute_instance_group.worker-nodes.instances[1].network_interface[0].nat_ip_address
}

output "WorkerNode-1_Int_IP" {
  value = yandex_compute_instance_group.worker-nodes.instances[1].network_interface[0].ip_address
}

output "Balancer_IP" {
  value = yandex_alb_load_balancer.alb.listener.0.endpoint.0.address.0.external_ipv4_address.0.address
}