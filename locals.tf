locals {

key = file("/root/.ssh/ycservice.pub")
ubukey = "ubuntu:${local.key}"
    }