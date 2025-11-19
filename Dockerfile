####
#  ci-env-dotnet
#    Continuous integration environment based upon .NET SDK ('current' support level image).
#    Additional SDKs:
#      .NET Core (all currently-supported .NET Core 'LTS' support level SDKs)
#      node.js (current LTS support level release).
####
ARG DOTNET_SDK_IMAGE=mcr.microsoft.com/dotnet/sdk:10.0.100
ARG TARGETPLATFORM
ARG BUILDPLATFORM

# https://github.com/dotnet/dotnet-docker/blob/main/README.sdk.md#full-tag-listing
ARG DOTNET_9_VERSION=9.0.307
# https://github.com/dotnet/dotnet-docker/blob/main/README.runtime.md#full-tag-listing
ARG DOTNET_9_RUNTIME_VERSION=9.0.11
# https://github.com/dotnet/dotnet-docker/blob/main/README.aspnet.md#full-tag-listing
ARG ASPNET_9_RUNTIME_VERSION=9.0.11

# https://github.com/dotnet/dotnet-docker/blob/main/README.sdk.md#full-tag-listing
ARG DOTNET_8_VERSION=8.0.416
# https://github.com/dotnet/dotnet-docker/blob/main/README.runtime.md#full-tag-listing
ARG DOTNET_8_RUNTIME_VERSION=8.0.22
# https://github.com/dotnet/dotnet-docker/blob/main/README.aspnet.md#full-tag-listing
ARG ASPNET_8_RUNTIME_VERSION=8.0.22

# https://hub.docker.com/_/microsoft-dotnet
# https://hub.docker.com/_/microsoft-dotnet-aspnet/
# https://hub.docker.com/_/microsoft-dotnet-runtime/
# https://hub.docker.com/_/microsoft-dotnet-sdk/
# https://hub.docker.com/_/node/
FROM ${DOTNET_SDK_IMAGE} AS base-ci-image

FROM base-ci-image AS ci-01-common-dependencies

# Install:
#   gnupg      - node.js installation dependency
#   jq         - to support loading project metadata from JSON
#   unzip      - dependency supporting AWS CLI installation
#   xz-utils   - tar dependency supporting node.js installation
#   zip        - to support compressing artifacts
RUN apt-get update && apt-get install \
  gnupg \
  jq \
  unzip \
  xz-utils \
  zip \
  -y \
  && rm -rf /var/lib/apt/lists/*

FROM ci-01-common-dependencies AS ci-02-with-nodejs

ARG NODE_VERSION=24.11.1

#   node.js
ENV NODE_VERSION=${NODE_VERSION}
#     See: https://github.com/nodejs/docker-node/blob/a364e16a23fb97ea9768e5adbae36f1de63f44e9/24/bookworm/Dockerfile
RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
    amd64) ARCH='x64';; \
    ppc64el) ARCH='ppc64le';; \
    s390x) ARCH='s390x';; \
    arm64) ARCH='arm64';; \
    armhf) ARCH='armv7l';; \
    i386) ARCH='x86';; \
    *) echo "unsupported architecture"; exit 1 ;; \
  esac \
  # use pre-existing gpg directory, see https://github.com/nodejs/docker-node/pull/1895#issuecomment-1550389150
  && export GNUPGHOME="$(mktemp -d)" \
  # gpg keys listed at https://github.com/nodejs/node#release-keys
  && set -ex \
  && for key in \
    5BE8A3F6C8A5C01D106C0AD820B1A390B168D356 \
    DD792F5973C6DE52C432CBDAC77ABFA00DDBF2B7 \
    CC68F5A3106FF448322E48ED27F5E38D5B0A215F \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
    C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
    108F52B48DB57BB0CC439B2997B01419BD92F80A \
    A363A499291CBBC940DD62E41F10027AF002F8B0 \
  ; do \
      { gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" && gpg --batch --fingerprint "$key"; } || \
      { gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" && gpg --batch --fingerprint "$key"; } ; \
  done \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && gpgconf --kill all \
  && rm -rf "$GNUPGHOME" \
  && grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
  && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  # smoke tests
  && node --version \
  && npm --version \
  && rm -rf /tmp/*

FROM ci-02-with-nodejs AS ci-03-with-aws-cli

#   AWS CLI
RUN mkdir "/aws-install" \
  && printf "\nDownloading AWS CLI...\n" \
  && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/aws-install/awscliv2.zip" \
  && printf "\n\nAWS CLI downloaded. Unzipping...\n" \
  && unzip "/aws-install/awscliv2.zip" -d "/aws-install"  \
  && printf "\n\nAWS CLI unzipped. Installing...\n" \
  && "/aws-install/aws/install" \
  && printf "\n\nAWS CLI installed. Removing install directory...\n" \
  && rm -rf "/aws-install"

FROM ci-03-with-aws-cli AS ci-04-with-docker-cli

#   Docker CLI
RUN apt-get update \
  && apt-get install \
  docker.io \
  -y \
  && rm -rf /var/lib/apt/lists/*

# .NET 8
FROM mcr.microsoft.com/dotnet/sdk:$DOTNET_8_VERSION AS dotnet-sdk-8
FROM mcr.microsoft.com/dotnet/aspnet:$ASPNET_8_RUNTIME_VERSION AS dotnet-aspnet-8
FROM mcr.microsoft.com/dotnet/runtime:$DOTNET_8_RUNTIME_VERSION AS dotnet-runtime-8

FROM ci-04-with-docker-cli AS ci-05-with-dotnet-8

COPY --from=dotnet-sdk-8 /usr/share/dotnet /usr/share/dotnet
COPY --from=dotnet-aspnet-8 /usr/share/dotnet /usr/share/dotnet
COPY --from=dotnet-runtime-8 /usr/share/dotnet /usr/share/dotnet

# .NET 9
FROM mcr.microsoft.com/dotnet/sdk:$DOTNET_9_VERSION AS dotnet-sdk-9
FROM mcr.microsoft.com/dotnet/aspnet:$ASPNET_9_RUNTIME_VERSION AS dotnet-aspnet-9
FROM mcr.microsoft.com/dotnet/runtime:$DOTNET_9_RUNTIME_VERSION AS dotnet-runtime-9

FROM ci-05-with-dotnet-8 AS ci-06-with-dotnet-9

COPY --from=dotnet-sdk-9 /usr/share/dotnet /usr/share/dotnet
COPY --from=dotnet-aspnet-9 /usr/share/dotnet /usr/share/dotnet
COPY --from=dotnet-runtime-9 /usr/share/dotnet /usr/share/dotnet

FROM ci-06-with-dotnet-9 AS ci-07-with-npm-global-packages

# Add global NPM packages
#   AWS CDK    - AWS infrastructure-as-code
#   TypeScript - Language support
RUN npm install -g aws-cdk typescript

FROM ci-07-with-npm-global-packages AS ci-08-with-dotnet-global-tools

# Add dotnet tools global tools to path for global tool installs
ENV PATH="${PATH}:/root/.dotnet/tools"

# .NET global tools are not installed due to segmentation fault thrown in qemu when installing on non-native architecture.

FROM ci-08-with-dotnet-global-tools AS final-ci-environment-image

# Add the 'cicee' containerized CI mount directory (/code) to Git safe directories.
#   This is required to allow Git commands to function in the containerized environment.
#   The 'cicee' tool's shell scripts use Git to create prerelease versions based upon current commit hash.
#   See: https://git-scm.com/docs/git-config#Documentation/git-config.txt-safedirectory
#   NOTE: The '/code' directory is not initialized in this image. Thus, this should not be a safety concern.
RUN git config --global --add safe.directory /code
