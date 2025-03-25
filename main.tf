terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "5.35.0"
    }
  }
}

provider "oci" {
  auth = "InstancePrincipal"
  region = var.region
}

# Create a VCN
resource "oci_core_vcn" "my_vcn" {
  compartment_id = var.compartment_id
  cidr_block     = "10.0.0.0/16"
  display_name   = "My VCN"
  dns_label      = "myvcn"  # Must be lowercase, max 15 chars, no hyphens
}

# Create a subnet
resource "oci_core_subnet" "vm_subnet" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.my_vcn.id
  cidr_block     = "10.0.1.0/24"
  display_name   = "VM Subnet"
  dns_label      = "vmsubnet"  # Must be lowercase, max 15 chars, no hyphens

  # Ensure instances in this subnet get a public IP (optional)
  prohibit_public_ip_on_vnic = false
}

# Create a security list with SSH access
resource "oci_core_security_list" "vm_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.my_vcn.id

  # Allow SSH (port 22) from anywhere
  ingress_security_rules {
    protocol = "6"  # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # Allow all outbound traffic
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}


resource "random_id" "suffix" {
  byte_length = 4
}

# Create an OCI instance
resource "oci_core_instance" "always_free_vm" {
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
  display_name = "${var.instance_prefix}-${random_id.suffix.hex}-${var.instance_name}"

}
