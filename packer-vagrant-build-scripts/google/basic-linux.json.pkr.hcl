locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "googlecompute" "basic-example" {
  project_id              = "test-pkr"
  source_image            = "debian-10-buster-v20210512"
  source_image_family     = "debian-10"
  zone                    = "us-east1-b"
  disk_size               = 50
  machine_type            = "n1-standard-2"
  ssh_username            = "vagrant"
  ssh_password            = "vagrant"
  ssh_wait_timeout        = "2800s"
  ssh_timeout             = "30m"

}

build {
  sources = ["sources.googlecompute.basic-example"]

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{ .Vars }} sudo -E -S sh '{{ .Path }}'"
    script          = "../scripts/post_install_vagrant_first-box.sh"
    only            = ["basic-example"]
  }

  post-processor "vagrant" {
    keep_input_artifact = false
    output              = "../build/{{ .BuildName }}-${local.timestamp}.box"
  }
}
