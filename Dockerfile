####
#  ci-env-dotnet
#    Continuous integration environment based upon .NET SDK ('current' support level image).
#    Additional SDKs:
#      .NET Core (all currently-supported .NET Core 'LTS' support level SDKs)
#      node.js (current LTS support level release).
####
ARG DOTNET_SDK_IMAGE=mcr.microsoft.com/dotnet/sdk:9.0.306

# https://hub.docker.com/_/microsoft-dotnet
# https://hub.docker.com/_/microsoft-dotnet-aspnet/
# https://hub.docker.com/_/microsoft-dotnet-runtime/
# https://hub.docker.com/_/microsoft-dotnet-sdk/
# https://hub.docker.com/_/node/
FROM ${DOTNET_SDK_IMAGE} AS build-environment

ARG NODE_VERSION=20.19.1

# https://github.com/dotnet/dotnet-docker/blob/main/README.sdk.md#full-tag-listing
ARG DOTNET_6_VERSION=6.0.428
ARG DOTNET_6_SHA_AMD64=04395f991ab50e4755ce1ae53e23592a7420b71b82160883bae3194dd1dfd5dcaed78743e4e0b4dd51ea43c49ec84b5643630707b3854f1471265dc98490d2f9
ARG DOTNET_6_SHA_ARM64=cb8454865ecb99ce557bd0a5741d3dc84657a45ea00f9b2a0f0593e94e4e661e898a5690df90cf0175bf5982973c19985a168998aaa975b7ac7a3bef2ecd05d2
# https://github.com/dotnet/dotnet-docker/blob/main/README.runtime.md#full-tag-listing
ARG DOTNET_6_RUNTIME_VERSION=6.0.36
ARG DOTNET_6_RUNTIME_SHA_AMD64=afb6018fcabec468ccd7ae2f1131d8c9de7f4de7645b8f0c223efbbdbfdc515fb0642a399ebfe372c02044416c4cae463c9c802cd156b9da4181efff0e33ee94
ARG DOTNET_6_RUNTIME_SHA_ARM64=aa9a35f181204199ac6c44863c4773f8967b25adce218e23ce2822b40b26c38edc1e4e2ff323dabb81ae049bc187f14d209ef1365e68970fd6c32af21f0a1d44
# https://github.com/dotnet/dotnet-docker/blob/main/README.aspnet.md#full-tag-listing
ARG ASPNET_6_RUNTIME_VERSION=6.0.36
ARG ASPNET_6_RUNTIME_SHA_AMD64=0e3d1dcc715bffbcb8ab8cb4fd72accbeed79ac40b7fd517961797a168f4301505044d2c1494a49b0e68103940bd6c178c8ae7bacf75f4b40ce82cc85624f6bd
ARG ASPNET_6_RUNTIME_SHA_ARM64=2a6a2dde7ba3aeee9145686ee32f1901a7aa6238ae8395ea3bad51770e227069272be83959b711d238210c377b66661e3cf039965f019b58cd44c08a982404a2

# https://github.com/dotnet/dotnet-docker/blob/main/README.sdk.md#full-tag-listing
ARG DOTNET_8_VERSION=8.0.415
ARG DOTNET_8_SHA_AMD64=0fc0499a857f161f7c35775bb3f50ac6f0333f02f5df21d21147d538eb26a9a87282d4ba3707181c46f3c09d22cdc984e77820a5953a773525d6f7b332deb7f2
ARG DOTNET_8_SHA_ARM64=c2efcccfd83690482d3314b23a9d9b53d41591795eb50e02857cb495dd1fde132f2c332dc243095463338d2dc6cd362cd7ea7ae3a9ce75b32ab54a517b91def8
# https://github.com/dotnet/dotnet-docker/blob/main/README.runtime.md#full-tag-listing
ARG DOTNET_8_RUNTIME_VERSION=8.0.21
ARG DOTNET_8_RUNTIME_SHA_AMD64=b5771f98f89bcb70ba18df234dd82f006ee3b241fe4863485ea649d7c428d12f2e14de620a4ec09f56b9b98b5216c5b216a47f0b5cd9011a383993eef6979015
ARG DOTNET_8_RUNTIME_SHA_ARM64=7eaeadbcca169b2fdd2ba078c242b775d17be887f0e058b936dd6f872c1b7ab3260a6852e398b84f4c9165d0f55bb0fcdebf8b3de26ff980ab7d3a43d320bd45
# https://github.com/dotnet/dotnet-docker/blob/main/README.aspnet.md#full-tag-listing
ARG ASPNET_8_RUNTIME_VERSION=8.0.21
ARG ASPNET_8_RUNTIME_SHA_AMD64=4aa9458d3de7b4ff960adcc4a655e4d7e4e6570e97791919113b8c9a55883964a60241daf3a70c60494cde1a61155d802339ec03b046466eac67298f0acc7289
ARG ASPNET_8_RUNTIME_SHA_ARM64=db04b085c4ce1d732e55be57efe771b4be4c6bcf9b5359fbf88993b19026d77e7e108a41ab0c447da100306df8dfde90bc9c206cefb1856f7da6b618b6ceda32

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

#   node.js
ENV NODE_VERSION=${NODE_VERSION}
#     See: https://github.com/nodejs/docker-node/blob/a54ad036b53ed4d64744aa5aba25e78be5e4e7b1/18/bookworm/Dockerfile
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
  # gpg keys listed at https://github.com/nodejs/node#release-keys
  && set -ex \
  && for key in \
  C0D6248439F1D5604AAFFB4021D900FFDB233756 \
  DD792F5973C6DE52C432CBDAC77ABFA00DDBF2B7 \
  CC68F5A3106FF448322E48ED27F5E38D5B0A215F \
  8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
  890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
  C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
  108F52B48DB57BB0CC439B2997B01419BD92F80A \
  A363A499291CBBC940DD62E41F10027AF002F8B0 \
  ; do \
  gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" || \
  gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" ; \
  done \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
  && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  # smoke tests
  && node --version \
  && npm --version

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

#   Docker CLI
RUN apt-get update \
  && apt-get install \
  docker.io \
  -y \
  && rm -rf /var/lib/apt/lists/*

# Install .NET 6 SDK
#   See: https://github.com/dotnet/dotnet-docker/tree/main/src/sdk/6.0/bullseye-slim/amd64/Dockerfile
#        https://github.com/dotnet/dotnet-docker/tree/main/src/sdk/6.0/bullseye-slim/arm64v8/Dockerfile
RUN if [ "$(dpkg --print-architecture)" = "arm64" ]; then \
  curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/${DOTNET_6_VERSION}/dotnet-sdk-${DOTNET_6_VERSION}-linux-arm64.tar.gz \
  && echo "${DOTNET_6_SHA_ARM64} dotnet.tar.gz" | sha512sum -c - ; \
  else \
  curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/${DOTNET_6_VERSION}/dotnet-sdk-${DOTNET_6_VERSION}-linux-x64.tar.gz \
  && echo "${DOTNET_6_SHA_AMD64} dotnet.tar.gz" | sha512sum -c - ; \
  fi \
  && mkdir -p /usr/share/dotnet \
  && tar -oxzf dotnet.tar.gz -C /usr/share/dotnet ./packs ./sdk ./sdk-manifests ./templates ./LICENSE.txt ./ThirdPartyNotices.txt \
  && rm dotnet.tar.gz \
  # Trigger first run experience by running arbitrary cmd
  && dotnet help

# Install .NET 6 runtime (for LTS tools)
#   See: https://github.com/dotnet/dotnet-docker/tree/main/src/runtime/6.0/bullseye-slim/amd64/Dockerfile
#        https://github.com/dotnet/dotnet-docker/tree/main/src/runtime/6.0/bullseye-slim/arm64v8/Dockerfile
RUN if [ "$(dpkg --print-architecture)" = "arm64" ]; then \
  curl -fSL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/${DOTNET_6_RUNTIME_VERSION}/dotnet-runtime-${DOTNET_6_RUNTIME_VERSION}-linux-arm64.tar.gz \
  && echo "${DOTNET_6_RUNTIME_SHA_ARM64}  dotnet.tar.gz" | sha512sum -c - ; \
  else \
  curl -fSL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/${DOTNET_6_RUNTIME_VERSION}/dotnet-runtime-${DOTNET_6_RUNTIME_VERSION}-linux-x64.tar.gz \
  && echo "${DOTNET_6_RUNTIME_SHA_AMD64}  dotnet.tar.gz" | sha512sum -c - ; \
  fi \
  && mkdir -p /usr/share/dotnet \
  && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet \
  && rm dotnet.tar.gz \
  # Trigger first run experience by running arbitrary cmd
  && dotnet help

# Install ASP.NET Core 6 runtime (for LTS tools)
#   See: https://github.com/dotnet/dotnet-docker/tree/main/src/aspnet/6.0/bullseye-slim/amd64/Dockerfile
#   See: https://github.com/dotnet/dotnet-docker/tree/main/src/aspnet/6.0/bullseye-slim/arm64v8/Dockerfile
RUN if [ "$(dpkg --print-architecture)" = "arm64" ]; then \
  curl -fSL --output aspnetcore.tar.gz https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/${ASPNET_6_RUNTIME_VERSION}/aspnetcore-runtime-${ASPNET_6_RUNTIME_VERSION}-linux-arm64.tar.gz \
  && echo "${ASPNET_6_RUNTIME_SHA_ARM64}  aspnetcore.tar.gz" | sha512sum -c - ; \
  else \
  curl -fSL --output aspnetcore.tar.gz https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/${ASPNET_6_RUNTIME_VERSION}/aspnetcore-runtime-${ASPNET_6_RUNTIME_VERSION}-linux-x64.tar.gz \
  && echo "${ASPNET_6_RUNTIME_SHA_AMD64}  aspnetcore.tar.gz" | sha512sum -c - ; \
  fi \
  && mkdir -p /usr/share/dotnet \
  && tar -ozxf aspnetcore.tar.gz -C /usr/share/dotnet \
  && rm aspnetcore.tar.gz \
  # Trigger first run experience by running arbitrary cmd
  && dotnet help

# Install .NET 8 SDK
#   See: https://github.com/dotnet/dotnet-docker/tree/main/src/sdk/8.0/bookworm-slim/amd64/Dockerfile
#        https://github.com/dotnet/dotnet-docker/tree/main/src/sdk/8.0/bookworm-slim/arm64v8/Dockerfile
RUN if [ "$(dpkg --print-architecture)" = "arm64" ]; then \
  curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/${DOTNET_8_VERSION}/dotnet-sdk-${DOTNET_8_VERSION}-linux-arm64.tar.gz \
  && echo "${DOTNET_8_SHA_ARM64} dotnet.tar.gz" | sha512sum -c - ; \
  else \
  curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/${DOTNET_8_VERSION}/dotnet-sdk-${DOTNET_8_VERSION}-linux-x64.tar.gz \
  && echo "${DOTNET_8_SHA_AMD64} dotnet.tar.gz" | sha512sum -c - ; \
  fi \
  && mkdir -p /usr/share/dotnet \
  && tar -oxzf dotnet.tar.gz -C /usr/share/dotnet ./packs ./sdk ./sdk-manifests ./templates ./LICENSE.txt ./ThirdPartyNotices.txt \
  && rm dotnet.tar.gz \
  # Trigger first run experience by running arbitrary cmd
  && dotnet help

# Install .NET 8 runtime (for LTS tools)
#   See: https://github.com/dotnet/dotnet-docker/tree/main/src/runtime/8.0/bookworm-slim/amd64/Dockerfile
#        https://github.com/dotnet/dotnet-docker/tree/main/src/runtime/8.0/bookworm-slim/arm64v8/Dockerfile
RUN if [ "$(dpkg --print-architecture)" = "arm64" ]; then \
  curl -fSL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/${DOTNET_8_RUNTIME_VERSION}/dotnet-runtime-${DOTNET_8_RUNTIME_VERSION}-linux-arm64.tar.gz \
  && echo "${DOTNET_8_RUNTIME_SHA_ARM64}  dotnet.tar.gz" | sha512sum -c - ; \
  else \
  curl -fSL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/${DOTNET_8_RUNTIME_VERSION}/dotnet-runtime-${DOTNET_8_RUNTIME_VERSION}-linux-x64.tar.gz \
  && echo "${DOTNET_8_RUNTIME_SHA_AMD64}  dotnet.tar.gz" | sha512sum -c - ; \
  fi \
  && mkdir -p /usr/share/dotnet \
  && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet \
  && rm dotnet.tar.gz \
  # Trigger first run experience by running arbitrary cmd
  && dotnet help

# Install ASP.NET Core 8 runtime (for LTS tools)
#   See: https://github.com/dotnet/dotnet-docker/tree/main/src/aspnet/8.0/bookworm-slim/amd64/Dockerfile
#   See: https://github.com/dotnet/dotnet-docker/tree/main/src/aspnet/8.0/bookworm-slim/arm64v8/Dockerfile
RUN if [ "$(dpkg --print-architecture)" = "arm64" ]; then \
  curl -fSL --output aspnetcore.tar.gz https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/${ASPNET_8_RUNTIME_VERSION}/aspnetcore-runtime-${ASPNET_8_RUNTIME_VERSION}-linux-arm64.tar.gz \
  && echo "${ASPNET_8_RUNTIME_SHA_ARM64}  aspnetcore.tar.gz" | sha512sum -c - ; \
  else \
  curl -fSL --output aspnetcore.tar.gz https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/${ASPNET_8_RUNTIME_VERSION}/aspnetcore-runtime-${ASPNET_8_RUNTIME_VERSION}-linux-x64.tar.gz \
  && echo "${ASPNET_8_RUNTIME_SHA_AMD64}  aspnetcore.tar.gz" | sha512sum -c - ; \
  fi \
  && mkdir -p /usr/share/dotnet \
  && tar -ozxf aspnetcore.tar.gz -C /usr/share/dotnet \
  && rm aspnetcore.tar.gz \
  # Trigger first run experience by running arbitrary cmd
  && dotnet help

# Add global NPM packages
#   AWS CDK    - AWS infrastructure-as-code
#   TypeScript - Language support
RUN npm install -g aws-cdk typescript

# Add dotnet tools global tools to path for tool installs
ENV PATH="${PATH}:/root/.dotnet/tools"
#   cicee - to provide a continuous integration shell function library
#     https://github.com/JeremiahSanders/cicee/blob/dev/docs/use/ci-library.md
#   coverlet - to support code coverage analysis
#     https://github.com/coverlet-coverage/coverlet/blob/master/Documentation/GlobalTool.md
#   fantomas - to support formatting and linting F#
#     https://github.com/fsprojects/fantomas/blob/master/docs/Documentation.md#using-the-command-line-tool
#   resharper command line tools - to provide .NET CI capabilities
#     https://www.jetbrains.com/help/resharper/ReSharper_Command_Line_Tools.html
RUN if [ "$(uname -m)" = "aarch64" ]; then \
  echo "Skipping dotnet commands for ARM64 environment due to 'dotnet tool install --global' installation errors."; \
  else \
  dotnet tool install --global fantomas-tool && \
  dotnet tool install --global coverlet.console && \
  dotnet tool install --global JetBrains.ReSharper.GlobalTools && \
  dotnet tool install --global cicee; \
  fi

# Add the 'cicee' containerized CI mount directory (/code) to Git safe directories.
#   This is required to allow Git commands to function in the containerized environment.
#   The 'cicee' tool's shell scripts use Git to create prerelease versions based upon current commit hash.
#   See: https://git-scm.com/docs/git-config#Documentation/git-config.txt-safedirectory
#   NOTE: The '/code' directory is not initialized in this image. Thus, this should not be a safety concern.
RUN git config --global --add safe.directory /code
