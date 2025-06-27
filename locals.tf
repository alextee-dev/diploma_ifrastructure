locals {

key = file("~/.ssh/ycservice.pub")
ubukey = "ubuntu:${local.key}"
    }