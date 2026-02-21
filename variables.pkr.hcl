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

variable "vm_vlan_tag" {
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