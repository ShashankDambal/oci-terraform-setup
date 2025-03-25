variable "availability_domain" {
  description = "Availability Domain for the instance"
  type        = string
}

variable "compartment_id" {
  description = "Compartment OCID where the instance will be created"
  type        = string
}

variable "region" {
  description = "OCI region"
  type        = string
}


variable "shape" {
  description = "Instance shape"
  type        = string
  default     = "VM.Standard.E2.1.Micro"  # Always Free shape
}

variable "subnet_id" {
  description = "Subnet OCID where the instance will be created"
  type        = string
}

variable "image_id" {
  description = "OCID of the OS image"
  type        = string
}

variable "ssh_public_key_file" {
  description = "Path to the SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "instance_name" {
  description = "Name of the Compute instance"
  type        = string
  default     = "AlwaysFreeVM"
}

