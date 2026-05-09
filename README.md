# Debian 13 Golden Image via Packer

Packer template for building a Debian 13 template VM on Proxmox VE.

# Usage
```shell
make build
```

# WSL
If packer runs from WSL, set: 

```hcl
wsl = true
host_ip = "WINDOWS_HOST_IP"
```

Port forward from Host to WSL:
```cmd
netsh interface portproxy add v4tov4 listenport=8802 listenaddress=0.0.0.0 connectport=8802 connectaddress=WSL_IP
```
