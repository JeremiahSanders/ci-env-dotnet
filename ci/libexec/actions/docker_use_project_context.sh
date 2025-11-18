#!/usr/bin/env bash

set -o errexit  # Fail or exit immediately if there is an error.
set -o nounset  # Fail if an unset variable is used.
set -o pipefail # Fail pipelines if any command errors, not just the last one.

function docker_use_project_context() {
  local context_name="${PROJECT_NAME}"

  function _loadContext() {
    docker buildx use "${context_name}" || docker buildx create \
      --driver docker-container \
      --name "${context_name}" \
      --bootstrap \
      --use
  }

  _loadContext &&
    printf "\nNow using buildx context '%s'.\n\n" "${context_name}"
}

export -f docker_use_project_context
