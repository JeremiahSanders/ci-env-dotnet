FROM docker:latest AS build-environment

# Adding /code to safe directories addresses this error: fatal: unsafe repository ('/code' is owned by someone else)

RUN apk add --no-cache \
    bash \
    git \
    jq && \
  git config --global --add safe.directory /code
