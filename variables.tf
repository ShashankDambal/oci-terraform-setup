variable "instance_prefix" {
  description = "Prefix for the instance name"
  type        = string
  default     = "myvm"
}

variable "vcn_cidr" {
  description = "CIDR block for the VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "compartment_id" {
  description = "OCI Compartment ID"
  type        = string
}

variable "region" {
  description = "OCI Region"
  type        = string
}

variable "availability_domain" {
  description = "OCI Availability Domain"
  type        = string
}

variable "shape" {
  description = "Instance shape"
  type        = string
}

variable "image_id" {
  description = "Image ID for the instance"
  type        = string
}

variable "ssh_public_key_file" {
  description = "Path to the SSH public key"
  type        = string
}

variable "instance_name" {
  description = "Instance name suffix"
  type        = string
  default     = "vm"
}
