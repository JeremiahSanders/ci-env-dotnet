#!/usr/bin/env bash

declare SCRIPT_LOCATION="$(dirname "${BASH_SOURCE[0]}")"
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "${SCRIPT_LOCATION}" && cd .. && pwd)}"

source "${PROJECT_ROOT}/ci/env.project.sh"

if [[ -f "${PROJECT_ROOT}/ci/env.local.sh" ]]; then
  source "${PROJECT_ROOT}/ci/env.local.sh"
fi

declare REPO_NAME="${DOCKER_IMAGE_REPOSITORY:-gnosian/ci-env-dotnet}"
declare BUILD_DATE_TIME="$(TZ="utc" date "+%Y%m%d-%H%M%S")"
declare TAG_NAME="${REPO_NAME}:interactive-${BUILD_DATE_TIME}"
docker build --pull --rm -f "Dockerfile" -t "${TAG_NAME}" "${PROJECT_ROOT}" &&
  printf "\n.NET: dotnet --info\n\n" &&
  docker run --rm "${TAG_NAME}" "dotnet" "--info" &&
  printf "\n\n.NET: dotnet tool list --global\n\n" &&
  docker run --rm "${TAG_NAME}" "dotnet" tool list --global &&
  printf "\n\nNode.js: node --version\n\n" &&
  docker run --rm "${TAG_NAME}" "node" --version &&
  printf "\n\nNode.js: npm list --global (global packages)\n\n" &&
  docker run --rm "${TAG_NAME}" "npm" list --global

docker image rm "${TAG_NAME}"
