#!/usr/bin/env bash

set -o errexit  # Fail or exit immediately if there is an error.
set -o nounset  # Fail if an unset variable is used.
set -o pipefail # Fail pipelines if any command errors, not just the last one.

function docker_publish_xarch_image() {
  function __push() {
    function __conditionallyPushLatest() {
      if [[ "${RELEASE_ENVIRONMENT:-false}" = true ]]; then
        docker buildx build \
          --file "${PROJECT_ROOT}/Dockerfile" \
          --tag "${DOCKER_IMAGE}" \
          --tag "${DOCKER_IMAGE_REPOSITORY}:latest" \
          --platform linux/amd64,linux/arm64 \
          --push .
      else
        docker buildx build \
          --file "${PROJECT_ROOT}/Dockerfile" \
          --tag "${DOCKER_IMAGE}" \
          --platform linux/amd64,linux/arm64 \
          --push .
      fi
    }
    printf "Preparing to push %s.\n\n" "${DOCKER_IMAGE}" &&
      __conditionallyPushLatest &&
      printf "\n\nPushed combined docker image %s.\n\n" "${DOCKER_IMAGE}"
  }

  docker_apply_environment &&
    require-var "DOCKER_IMAGE" &&
    require-var "DOCKER_IMAGE_REPOSITORY" &&
    docker_use_project_context &&
    __push
}

export -f docker_publish_xarch_image
