#!/usr/bin/env bash
# shellcheck disable=SC2155

###
# Compose the project's artifacts, e.g., compiled binaries, Docker images.
#   This workflow performs all steps required to create the project's output.
#
#   This script expects a CICEE CI library environment (which is provided when using 'cicee lib exec').
#   For CI library environment details, see: https://github.com/JeremiahSanders/cicee/blob/main/docs/use/ci-library.md
#
# How to use:
#   Modify the "ci-compose" function, below, to execute the steps required to produce the project's artifacts.
###

set -o errexit  # Fail or exit immediately if there is an error.
set -o nounset  # Fail if an unset variable is used.
set -o pipefail # Fail pipelines if any command errors, not just the last one.

function ci-compose() {
  printf "Composing build artifacts...\n\n"

  __conditionallyTagLatest() {
    if [[ "${RELEASE_ENVIRONMENT:-false}" = true ]]; then
      docker tag "${DOCKER_IMAGE}" "${DOCKER_IMAGE_REPOSITORY}:latest"
    fi
  }

  ci-docker-build &&
    __conditionallyTagLatest

  printf "Composition complete.\n"
}

export -f ci-compose
