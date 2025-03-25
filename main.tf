terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "5.35.0"
    }
  }
}

provider "oci" {
  auth   = "InstancePrincipal"
  region = var.region
}

# Create a VCN
resource "oci_core_vcn" "my_vcn" {
  compartment_id = var.compartment_id
  cidr_block     = "10.0.0.0/16"
  display_name   = "My VCN"
  dns_label      = "myvcn"
}

# Create a subnet
resource "oci_core_subnet" "vm_subnet" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.my_vcn.id
  cidr_block     = "10.0.1.0/24"
  display_name   = "VM Subnet"
  dns_label      = "vmsubnet"
  prohibit_public_ip_on_vnic = false
}

# Create a security list
resource "oci_core_security_list" "vm_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.my_vcn.id

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

# Create first VM instance
resource "oci_core_instance" "vm_1" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  shape              = var.shape

  create_vnic_details {
    subnet_id = oci_core_subnet.vm_subnet.id
  }

  source_details {
    source_type = "image"
    source_id   = var.image_id
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file)
  }
  display_name = "${var.instance_prefix}-${random_id.suffix.hex}-vm-1"
}

# Create second VM instance
resource "oci_core_instance" "vm_2" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  shape              = var.shape

  create_vnic_details {
    subnet_id = oci_core_subnet.vm_subnet.id
  }

  source_details {
    source_type = "image"
    source_id   = var.image_id
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file)
  }
  display_name = "${var.instance_prefix}-${random_id.suffix.hex}-vm-2"
}

# Create Load Balancer
resource "oci_load_balancer" "app_lb" {
  compartment_id = var.compartment_id
  display_name   = "app-load-balancer"
  shape          = "flexible"
  subnet_ids     = [oci_core_subnet.vm_subnet.id]

  shape_details {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 100
  }
}

# Define Backend Set
resource "oci_load_balancer_backend_set" "backend_set" {
  name             = "backend-set-1"
  load_balancer_id = oci_load_balancer.app_lb.id
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol = "HTTP"
    url_path = "/"
    port     = 80
  }
}

# Attach VM 1 to Load Balancer
resource "oci_load_balancer_backend" "backend_vm1" {
  load_balancer_id = oci_load_balancer.app_lb.id
  backendset_name = oci_load_balancer_backend_set.backend_set.name
  ip_address       = oci_core_instance.vm_1.private_ip
  port             = 80
}

# Attach VM 2 to Load Balancer
resource "oci_load_balancer_backend" "backend_vm2" {
  load_balancer_id = oci_load_balancer.app_lb.id
  backendset_name = oci_load_balancer_backend_set.backend_set.name
  ip_address       = oci_core_instance.vm_2.private_ip
  port             = 80
}

# Create Load Balancer Listener
resource "oci_load_balancer_listener" "http_listener" {
  load_balancer_id         = oci_load_balancer.app_lb.id
  name                     = "http-listener"
  default_backend_set_name = oci_load_balancer_backend_set.backend_set.name
  port                     = 80
  protocol                 = "HTTP"
}
