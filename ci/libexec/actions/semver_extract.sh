#!/usr/bin/env bash

set -o errexit  # Fail or exit immediately if there is an error.
set -o nounset  # Fail if an unset variable is used.
set -o pipefail # Fail pipelines if any command errors, not just the last one.


# Extracts a version segment from a SemVer 2 string.
# First parameter: SemVer 2 string
# Second parameter: major/minor/patch
semver_extract() {
  local version="$1"
  local semVerSegment="$2"

  # Strip off pre-release (-...) and build metadata (+...)
  local base="${version%%[-+]*}"

  # Split into major/minor/patch
  IFS='.' read -r major minor patch <<< "$base"

  case "$semVerSegment" in
    major)
      echo "$major"
      ;;
    minor)
      echo "$major.$minor"
      ;;
    patch)
      echo "$major.$minor.$patch"
      ;;
    *)
      echo "Error: semVerSegment must be 'major', 'minor', or 'patch'" >&2
      return 1
      ;;
  esac
}


export -f semver_extract
