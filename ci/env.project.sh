#!/usr/bin/env bash

set -o errexit  # Fail or exit immediately if there is an error.
set -o nounset  # Fail if an unset variable is used.
set -o pipefail # Fail pipelines if any command errors, not just the last one.

printf "\nInitializing project CI environment.\n"

#--
# Initialize Project CI Environment
#--

export DOCKER_IMAGE_REPOSITORY="gnosian/ci-env-dotnet"

export PROJECT_VERSION_MAJOR="$(semver_extract ${PROJECT_VERSION} major)"
export PROJECT_VERSION_MINOR="$(semver_extract ${PROJECT_VERSION} minor)"

printf "\nProject CI environment initialized.\n"
