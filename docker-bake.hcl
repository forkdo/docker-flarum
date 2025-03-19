variable "GHCR_IMAGE" {
  default = "ghcr.io/forkdo/flarum"
}

variable "DOCKER_IMAGE" {
  default = "docker.io/forkdo/flarum"
}

## Special target: https://github.com/docker/metadata-action#bake-definition
target "docker-metadata-action" {}

target "_image" {
    inherits = ["docker-metadata-action"]
}

target "_common" {
    labels = {
        "org.opencontainers.image.source" = "https://github.com/forkdo/docker-flarumc"
        "org.opencontainers.image.documentation" = "https://github.com/forkdo/docker-flarum"
        "org.opencontainers.image.authors" = "Jetsung Chan<i@jetsung.com>"
    }
    context = "."
    dockerfile = "Dockerfile"
    args = {
        VERSION="v1.8"
    }
    platforms = ["linux/amd64"]
}

group "dev" {
  targets = ["stable", "edge"]
}

target "stable" {
    inherits = ["_common", "_image"]
    args = {
        VERSION="v1.8.0"
    }
    tags = ["${GHCR_IMAGE}:dev"]
}

target "edge" {
    inherits = ["_common", "_image"]
    args = {
        VERSION="v2.0.0"
    }
    tags = ["${GHCR_IMAGE}:dev-edge"]
}

group "main" {
  targets = ["main-stable", "main-edge"]
}

target "main-stable" {
    inherits = ["stable"]
    platforms = ["linux/amd64","linux/arm64"]
    tags = [
      "${GHCR_IMAGE}:1.8",
      "${GHCR_IMAGE}:latest"
    ]
}

target "main-edge" {
    inherits = ["edge"]
    platforms = ["linux/amd64","linux/arm64"]
    tags = [
      "${GHCR_IMAGE}:2.0",
      "${GHCR_IMAGE}:edge"
    ]
}

group "all" {
  targets = ["all-stable", "all-edge"]
}

target "all-stable" {
    inherits = ["main-stable"]
    tags = [
      "${GHCR_IMAGE}:1.8",
      "${GHCR_IMAGE}:latest",
      "${DOCKER_IMAGE}:1.8",
      "${DOCKER_IMAGE}:latest"
    ]
}

target "all-edge" {
    inherits = ["main-edge"]
    tags = [
      "${GHCR_IMAGE}:2.0",
      "${GHCR_IMAGE}:edge",
      "${DOCKER_IMAGE}:2.0",
      "${DOCKER_IMAGE}:edge"
    ]
}
