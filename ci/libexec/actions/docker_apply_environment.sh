#!/usr/bin/env bash

set -o errexit  # Fail or exit immediately if there is an error.
set -o nounset  # Fail if an unset variable is used.
set -o pipefail # Fail pipelines if any command errors, not just the last one.

function docker_apply_environment() {
  require-var "PROJECT_VERSION_DIST" "PROJECT_NAME"
  DOCKER_IMAGE_TAG="${DOCKER_IMAGE_TAG:-${PROJECT_VERSION_DIST}}"
  DOCKER_IMAGE_REPOSITORY="${DOCKER_IMAGE_REPOSITORY:-${PROJECT_NAME}}"
  DOCKER_IMAGE="${DOCKER_IMAGE_REPOSITORY}:${DOCKER_IMAGE_TAG}"

  export DOCKER_IMAGE_TAG DOCKER_IMAGE_REPOSITORY DOCKER_IMAGE
}

export -f docker_apply_environment
