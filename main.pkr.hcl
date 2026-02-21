packer {
  required_plugins {
    proxmox = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

locals {
  preseed_host = var.wsl ? var.host_ip : "{{ .HTTPIP }}"
}

source "proxmox-iso" "debian" {
  proxmox_url              = var.proxmox_api_url
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true

  node    = "pve"
  vm_id   = 10000
  vm_name = "debian13-template"

  boot_iso {
    type             = "scsi"
    iso_url          = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.3.0-amd64-netinst.iso"
    iso_checksum     = "sha256:c9f09d24b7e834e6834f2ffa565b33d6f1f540d04bd25c79ad9953bc79a8ac02"
    iso_storage_pool = "local"
    unmount          = true
  }

  qemu_agent = true

  scsi_controller = "virtio-scsi-pci"

  disks {
    disk_size    = "20G"
    storage_pool = var.disk_storage
    type         = "scsi"
  }

  cores    = "4"
  memory   = "4096"
  cpu_type = "host"

  machine = "q35"
  bios    = "ovmf"

  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = "false"
    vlan_tag = var.vm_vlan_tag
  }

  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"

  boot_command = [
    "<wait><wait>",
    "e",
    "<wait>",
    "<down><down><down><end>",
    " auto ",
    "priority=critical ",
    "DEBCONF_DEBUG=5 ",
    "interface=auto ",
    "netcfg/disable_dhcp=false ",
    "preseed/url=http://${local.preseed_host}:{{ .HTTPPort }}/preseed.cfg ",
    "debian-installer/locale=en_US.UTF-8 ",
    "console-keymaps-at/keymap=us ",
    "keyboard-configuration/xkb-keymap=us ",
    "<f10>"
  ]

  boot_key_interval = "30ms"
  boot_wait         = "10s"

  http_content = {
    "/preseed.cfg" = templatefile("./preseed/preseed.pkrtpl.hcl", {
      root_password = var.root_password
    })
  }
  http_port_min  = 8802
  http_port_max  = 8802

  ssh_username = "root"
  ssh_password = var.root_password

  ssh_timeout = "20m"
}

build {
  name    = "debian"
  sources = ["source.proxmox-iso.debian"]

  provisioner "shell" {
    inline = [
      "set -x",
      "export DEBIAN_FRONTEND=noninteractive",
      "apt-get update",
      "apt-get install -y mc htop curl wget vim git",
      "cd /tmp",
      "curl -LO https://github.com/prometheus/node_exporter/releases/download/v${var.node_exporter_version}/node_exporter-${var.node_exporter_version}.linux-amd64.tar.gz",
      "tar xzf node_exporter-${var.node_exporter_version}.linux-amd64.tar.gz",
      "cp node_exporter-${var.node_exporter_version}.linux-amd64/node_exporter /usr/local/bin/",
      "rm -rf node_exporter*",
      "useradd --no-create-home --shell /usr/sbin/nologin node_exporter || true",
      "cat > /etc/systemd/system/node_exporter.service <<'EOF'\n[Unit]\nDescription=Node Exporter\nAfter=network.target\n\n[Service]\nUser=node_exporter\nGroup=node_exporter\nType=simple\nExecStart=/usr/local/bin/node_exporter\nRestart=always\n\n[Install]\nWantedBy=multi-user.target\nEOF",
      "chown node_exporter:node_exporter /usr/local/bin/node_exporter",
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sh get-docker.sh",
      "systemctl enable node_exporter",
      "apt-get install -y systemd-resolved",
      "apt-get remove -y ifupdown resolvconf",
      "apt-get autoremove -y",
      "systemctl enable systemd-resolved",
      "rm -f /etc/resolv.conf",
      "ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf",
      "systemctl enable systemd-networkd",
      "mkdir -p /etc/cloud/cloud.cfg.d",
      "cat > /etc/cloud/cloud.cfg.d/99-network-renderer.cfg << 'EOF'",
      "system_info:",
      "  network:",
      "    renderers: ['networkd']",
      "EOF",
      "systemctl daemon-reload",
    ]
  }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; /bin/bash {{ .Path }}"
    inline = [
      "set -x",
      "cloud-init clean --logs --seed",
      "rm -rf /var/lib/cloud/instances/*",
      "rm -f /etc/ssh/ssh_host_*",
      "truncate -s 0 /etc/machine-id",
      "rm -f /var/lib/dbus/machine-id",
      "ln -s /etc/machine-id /var/lib/dbus/machine-id",
      "rm -rf /etc/systemd/network/*",
      "rm -f /var/lib/systemd/network/*",
      "truncate -s 0 /etc/resolv.conf",
      "find /var/log -type f -exec truncate --size 0 {} \\;",
      "history -c",
      "rm -f /root/.bash_history",
      "apt-get clean",
      "sync"
    ]
  }
}