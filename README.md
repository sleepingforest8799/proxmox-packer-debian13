# Debian 13 Golden Image via Packer

# Vars
### variables.auto.pkr.hcl
```sh
proxmox_api_url = ""
proxmox_api_token_id = ""
proxmox_api_token_secret = ""
vm_vlan_tag = 
root_password = ""
node_exporter_version = ""
disk_storage = ""
wsl = ""
host_ip = ""
```

# WSL
```cmd
netsh interface portproxy add v4tov4 listenport=8802 listenaddress=0.0.0.0 connectport=8802 connectaddress=WSL_IP
```

