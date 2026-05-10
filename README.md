# Debian 13 Golden Image via Packer

Packer template for building a Debian 13 template VM on Proxmox VE.

# Usage
```shell
make build
```

# Permissions
```shell
pveum user add packer@pve
pveum user token add packer@pve provider --privsep 1
pveum roleadd Packer -privs "Datastore.Audit Datastore.AllocateSpace Datastore.AllocateTemplate Sys.Audit VM.Allocate VM.Clone VM.Audit VM.Console VM.Monitor VM.PowerMgmt VM.Config.CDROM VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Config.Cloudinit VM.GuestAgent.Audit Pool.Audit Pool.Allocate SDN.Use"
pveum aclmod / --users packer@pve --roles Packer
pveum aclmod / --tokens "packer@pve\!provider" --roles Packer
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
