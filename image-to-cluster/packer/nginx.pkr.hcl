packer {
  required_plugins {
    docker = {
      version = ">= 1.0.8"
      source  = "github.com/hashicorp/docker"
    }
  }
}

variable "image_name" {
  type    = string
  default = "custom-nginx"
}

variable "image_tag" {
  type    = string
  default = "latest"
}

source "docker" "nginx" {
  image  = "nginx:alpine"
  commit = true
  changes = [
    "EXPOSE 80",
    "CMD [\"nginx\", \"-g\", \"daemon off;\"]"
  ]
}

build {
  name = "nginx-custom"
  
  sources = ["source.docker.nginx"]

  # Copie du fichier index.html personnalisé
  provisioner "file" {
    source      = "../index.html"
    destination = "/usr/share/nginx/html/index.html"
  }

  # Configuration Nginx (optionnel)
  provisioner "shell" {
    inline = [
      "echo 'Image Nginx personnalisée créée avec succès'",
      "echo 'Fichier index.html copié dans /usr/share/nginx/html/'",
      "ls -lah /usr/share/nginx/html/"
    ]
  }

  # Tag de l'image
  post-processor "docker-tag" {
    repository = var.image_name
    tags       = [var.image_tag]
  }
}
