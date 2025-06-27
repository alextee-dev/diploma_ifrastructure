[all]
node1 ansible_host=${control_nat_ip} ip=${control_int_ip}
node2 ansible_host=${worker0_nat_ip} ip=${worker0_int_ip}
node3 ansible_host=${worker1_nat_ip} ip=${worker1_int_ip}

[kube_control_plane]
node1

[etcd]
node1

[kube_node]
node2
node3

[calico_rr]

[k8s_cluster:children]
kube_control_plane
kube_node