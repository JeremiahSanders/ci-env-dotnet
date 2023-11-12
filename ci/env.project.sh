#!/usr/bin/env bash

set -o errexit  # Fail or exit immediately if there is an error.
set -o nounset  # Fail if an unset variable is used.
set -o pipefail # Fail pipelines if any command errors, not just the last one.

printf "\nInitializing project CI environment.\n"

#--
# Initialize Project CI Environment
#--

export DOCKER_IMAGE_REPOSITORY="gnosian/ci-env-dotnet"

printf "\nProject CI environment initialized.\n"
