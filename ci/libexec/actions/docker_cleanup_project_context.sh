#!/usr/bin/env bash

set -o errexit  # Fail or exit immediately if there is an error.
set -o nounset  # Fail if an unset variable is used.
set -o pipefail # Fail pipelines if any command errors, not just the last one.

function docker_cleanup_project_context() {
  function _cleanup(){
    local context_name="${PROJECT_NAME}"
    printf "Removing Docker buildx context: %s ...\n" "${BUILDX_CONTEXT_NAME}" &&
      docker buildx rm "${context_name}" &&
      printf "Removed Docker buildx context: %s\n\n" "${BUILDX_CONTEXT_NAME}"
  }

  if [[ "${DOCKER_USE_PERSISTENT_BUILDX_CONTEXT:-}" != "true" ]]; then
    _cleanup
  else
    printf "DOCKER_USE_PERSISTENT_BUILDX_CONTEXT was true.\nSkipping Docker buildx context cleanup.\n\n"
  fi
}

export -f docker_cleanup_project_context
