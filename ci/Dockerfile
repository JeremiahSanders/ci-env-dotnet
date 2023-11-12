FROM mcr.microsoft.com/dotnet/sdk:6.0

# Install:
#   Docker CLI, jq
# Adding /code to safe directories addresses this error: fatal: unsafe repository ('/code' is owned by someone else)
RUN apt-get update \
  && apt-get install \
  apt-transport-https \
  ca-certificates \
  curl \
  git \
  gnupg-agent \
  jq \
  software-properties-common \
  -y \
  && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
  && add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/debian \
  $(lsb_release -cs) \
  stable" \
  && apt-get update \
  && apt-get install \
  docker-ce-cli \
  -y \
  && rm -rf /var/lib/apt/lists/* \
  && git config --global --add safe.directory /code
