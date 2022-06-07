# main file

# provider info
provider "proxmox" {
    pm_api_url = "https://${var.proxmox_host}:8006/api2/json"
    pm_tls_insecure = true

    # Authenticate on API
    pm_api_token_id = var.pm_api_token_id
    pm_api_token_secret = var.pm_api_token_secret  
    
    # Set PM timout (default value is too low in this version of Proxmox)
    pm_timeout = 600
  
    # Uncomment the below for debugging.
    # pm_log_enable = true
    # pm_log_file = "terraform-plugin-proxmox.log"
    # pm_debug = true
    # pm_log_levels = {
    # _default = "debug"
    # _capturelog = ""
    # }
}

resource "proxmox_vm_qemu" "proxmox-fedora-template" {
  count = var.vm_count# just want 1 for now, set to 0 and apply to destroy VM
  name = "${var.vm_name_input}-${count.index + 1}" #count.index starts at 0, so + 1 means this VM will be named test-vm-1 in proxmox

  # target node
  target_node = var.target_node

  # vm template to clone
  clone = var.template_name[var.vm_name_input]

  # VM ID
  vmid = "${count.index+var.vm_ID}"

  # define hardware
  bios              = "ovmf" # required for VM to boot
  os_type           = "cloud-init"
  cores             = 1
  sockets           = 1
  cpu               = "host"
  memory            = 1024
  scsihw            = "virtio-scsi-pci"
  bootdisk          = "scsi0"
  disk {
    slot              = 0
    size            = "10G"
    type            = "scsi"
    storage         = "local-lvm"
    iothread        = 1
  }
  network {
    model = "virtio"
    bridge = "vmbr0"
  }
  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  # ssh keys from variable file
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}