#!/usr/bin/env bash

set -o errexit  # Fail or exit immediately if there is an error.
set -o nounset  # Fail if an unset variable is used.
set -o pipefail # Fail pipelines if any command errors, not just the last one.

function docker_build_xarch_image() {
  function _build() {
    docker buildx build \
        --file "${PROJECT_ROOT}/Dockerfile" \
        --tag "${DOCKER_IMAGE}" \
        --platform linux/amd64,linux/arm64 \
        . &&
      printf "\n\nBuilt combined docker image %s.\nImage is NOT loaded in Docker host.\n\n" "${DOCKER_IMAGE}"
  }

  docker_apply_environment &&
    require-var "DOCKER_IMAGE" &&
    docker_use_project_context &&
    _build
}

export -f docker_build_xarch_image
