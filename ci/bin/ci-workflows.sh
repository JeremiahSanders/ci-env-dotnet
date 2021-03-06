#!/usr/bin/env bash
# shellcheck disable=SC2155

###
# Project CI Workflow Composition Library.
#   Contains functions which execute the project's high-level continuous integration tasks.
#
# How to use:
#   Update the "workflow compositions" in this file to perform each of the named continuous integration tasks.
#   Add additional workflow functions as needed. Note: Functions must be executed
###

set -o errexit  # Fail or exit immediately if there is an error.
set -o nounset  # Fail if an unset variable is used.
set -o pipefail # Fail pipelines if any command errors, not just the last one.

# Infer this script has been sourced based upon WORKFLOWS_SCRIPT_LOCATION being non-empty.
if [[ -n "${WORKFLOWS_SCRIPT_LOCATION:-}" ]]; then
  # Workflows are already sourced. Exit.
  (return 0 2>/dev/null) || exit 0
fi

# Context
WORKFLOWS_SCRIPT_LOCATION="${BASH_SOURCE[0]}"
declare WORKFLOWS_SCRIPT_DIRECTORY="$(dirname "${WORKFLOWS_SCRIPT_LOCATION}")"
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "${WORKFLOWS_SCRIPT_DIRECTORY}" && cd ../.. && pwd)}"

# Load the CICEE continuous integration action library (by 'cicee lib' or the specific location CICEE mounts it to).
if [[ -n "$(command -v cicee)" ]]; then
  source "$(cicee lib)"
else
  # CICEE mounts the Bash CI action library at /opt/ci-lib/bash/ci.sh.
  source "/opt/ci-lib/bash/ci.sh"
fi

####
# BEGIN Workflow Compositions
#     These commands are executed by CI entrypoint scripts, e.g., publish.sh.
#     By convention, each CI workflow function begins with "ci-".
####

#--
# Validate the project's source, e.g. run tests, linting.
#--
ci-validate() {
  ci-docker-build
}

#--
# Compose the project's artifacts, e.g., compiled binaries, Docker images.
#--
ci-compose() {
  __conditionallyTagLatest() {
    if [[ "${RELEASE_ENVIRONMENT:-false}" = true ]]; then
      docker tag "${DOCKER_IMAGE}" "${DOCKER_IMAGE_REPOSITORY}:latest"
    fi
  }

  ci-docker-build &&
    __conditionallyTagLatest
}

#--
# Publish the project's artifact composition.
#--
ci-publish() {
  __conditionallyPushLatest() {
    if [[ "${RELEASE_ENVIRONMENT:-false}" = true ]]; then
      docker push "${DOCKER_IMAGE_REPOSITORY}:latest"
    fi
  }

  docker login --username "${DOCKER_USERNAME}" --password "${DOCKER_PASSWORD}" &&
    ci-docker-push &&
    __conditionallyPushLatest
}

export -f ci-compose
export -f ci-publish
export -f ci-validate

####
# END Workflow Compositions
####
