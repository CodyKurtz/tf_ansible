# Configure instance
resource "google_compute_instance" "default" {
  name         = "webserver"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  # Tag instance for firewall assignment
  tags = ["web"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  # Add networking to instance
  network_interface {
    network = "default"
    access_config {
    }
  }

  # Upload SSH keys for access
  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.public_key)}"
  }

  # Copy Ansible playbook to remote instance
  provisioner "file" {
    source      = "nginx_install.yml"
    destination = "/home/${var.ssh_user}/nginx_install.yml"

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.private_key)
      host        = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
    }
  }

  # Install Ansible on the remote instance and run it
  provisioner "remote-exec" {
    inline = [
      "until [ -f /var/lib/cloud/instance/boot-finished ]; do",
      "sleep 1",
      "done",
      "sudo apt update",
      "sudo apt install -y software-properties-common",
      "sudo apt-add-repository --yes --update ppa:ansible/ansible",
      "sudo apt install -y ansible",
      "ansible-playbook -c local -i \"localhost,\" nginx_install.yml",
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.private_key)
      host        = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
    }
  }
}