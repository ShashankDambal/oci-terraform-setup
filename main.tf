terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "5.35.0"
    }
  }
}

provider "oci" {
  auth = "InstancePrincipal"  # Change to "APIKey" if running locally
  region = var.region
}

resource "oci_core_instance" "always_free_vm" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  shape              = var.shape

  create_vnic_details {
    subnet_id = var.subnet_id
  }

  source_details {
    source_type = "image"
    source_id   = var.image_id
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file)
  }

  display_name = var.instance_name
}

