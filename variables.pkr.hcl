variable "proxmox_api_url" {
  type    = string
  default = env("PROXMOX_API_URL")
}

variable "proxmox_api_token_id" {
  type    = string
  default = env("PROXMOX_API_TOKEN_ID")
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
  default   = env("PROXMOX_API_TOKEN_SECRET")
}

variable "proxmox_node_name" {
  type = string
}

variable "vlan_id" {
  type = number
  default = null
}

variable "node_exporter_version" {
  type = string
}

variable "root_password" {
  type = string
}

variable "disk_storage" {
  type = string
}

variable "wsl" {
  type = bool
}

variable "host_ip" {
  type = string
}

variable "vm_id" {
  type = number
}

variable "vm_name" {
  type = string
}

variable "iso_url" {
  type = string
}

variable "iso_hash" {
  type = string
}