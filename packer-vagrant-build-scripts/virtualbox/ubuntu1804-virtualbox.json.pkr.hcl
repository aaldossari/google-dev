
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "virtualbox-iso" "ubuntu1804-virtualbox" {
  boot_command            = [
    "<esc><wait>",
    "<esc><wait>",
    "<enter><wait>",
    "/install/vmlinuz<wait>",
    " auto<wait>",
    " console-setup/ask_detect=false<wait>",
    " console-setup/layoutcode=us<wait>",
    " console-setup/modelcode=pc105<wait>",
    " debconf/frontend=noninteractive<wait>",
    " debian-installer=en_US<wait>",
    " fb=false<wait>",
    " initrd=/install/initrd.gz<wait>",
    " kbd-chooser/method=us<wait>",
    " keyboard-configuration/layout=USA<wait>",
    " keyboard-configuration/variant=USA<wait>",
    " locale=en_US<wait>",
    " netcfg/get_domain=vm<wait>",
    " netcfg/get_hostname=vagrant<wait>",
    " grub-installer/bootdev=/dev/sda<wait>",
    " noapic<wait>",
    " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed/preseed.cfg<wait>",
    " -- <wait>",
    "<enter><wait>"
  ]
  vm_name                 = "first-box"
  boot_wait               = "15s"
  disk_size               = 10000
  guest_additions_mode    = "disable"
  guest_additions_path    = "VBoxGuestAdditions_{{ .Version }}.iso"
  guest_os_type           = "Ubuntu_64"
  http_directory          = "."
  http_port_min           = 9001
  http_port_max           = 9050
  iso_urls                = ["http://cdimage.ubuntu.com/ubuntu/releases/bionic/release/ubuntu-18.04.5-server-amd64.iso"]
  iso_checksum            = "sha256:8c5fc24894394035402f66f3824beb7234b757dd2b5531379cb310cedfdf0996"
  shutdown_command        = "echo 'vagrant' | sudo -S shutdown -P now"
  ssh_wait_timeout        = "20000s"
  ssh_username            = "vagrant"
  ssh_password            = "vagrant"
  ssh_port                = 22
  vboxmanage              = [["modifyvm", "{{ .Name }}", "--memory", "${var.memory_amount}"]]
  virtualbox_version_file = ".vbox_version"
  headless                = "${var.headless_build}"
  cpus                    = "${var.cpu_amount}"
}


build {
  sources = ["source.virtualbox-iso.ubuntu1804-virtualbox"]


  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{ .Vars }} sudo -E -S sh '{{ .Path }}'"
    script          = "../scripts/post_install_vagrant_first-box.sh"
    only            = ["virtualbox-iso.ubuntu1804-virtualbox"]
  }

  post-processor "vagrant" {
    keep_input_artifact = false
    output              = "../build/{{ .BuildName }}-${local.timestamp}.box"
  }
}
