#!/usr/bin/env bash

# Fail or exit immediately if there is an error.
set -o errexit
# Fail if an unset variable is used.
set -o nounset
# Sets the exit code of a pipeline to that of the rightmost command to exit with a non-zero status,
# or zero if all commands of the pipeline exit successfully.
set -o pipefail

printf "\nInitializing project CI environment.\n"

#--
# Initialize Project CI Environment
#--

export DOCKER_IMAGE_REPOSITORY="gnosian/ci-env-dotnet"

printf "\nProject CI environment initialized.\n"
