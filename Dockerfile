####
#  ci-env-dotnet
#    Continuous integration environment based upon .NET SDK ('current' support level image).
#    Additional SDKs:
#      .NET Core (all currently-supported .NET Core 'LTS' support level SDKs)
#      node.js (current LTS support level release).
####
ARG DOTNET_SDK_IMAGE=mcr.microsoft.com/dotnet/sdk:8.0.101

# https://hub.docker.com/_/microsoft-dotnet
# https://hub.docker.com/_/microsoft-dotnet-aspnet/
# https://hub.docker.com/_/microsoft-dotnet-runtime/
# https://hub.docker.com/_/microsoft-dotnet-sdk/
# https://hub.docker.com/_/node/
FROM ${DOTNET_SDK_IMAGE} AS build-environment

ARG NODE_VERSION=18.18.2
ARG DOTNET_7_VERSION=7.0.405
ARG DOTNET_7_SHA_AMD64=6cdf82af56f920c87315209f5b5166126e97b13b6d715b6507ddbc9a2eb618f812e43686b79de810ae6a21e0fb5a8e04d68a004f00a07533c8b664f9c889b5b0
ARG DOTNET_7_SHA_ARM64=35c3b0036324f0d5a1711859f318863a2f24dd43d61518b38acffe9e278ee203007bf620d783ac706a615175b9c15d348cb9386c800aac219fb23537c03b919b
ARG DOTNET_7_RUNTIME_VERSION=7.0.15
ARG DOTNET_7_RUNTIME_SHA_AMD64=3cec6eabe448ccf5105c2203928a6fe00e343f1f0d97c79614d41c198548a20659113b9507da95b63dedbd3caa6a66bf5f3750f4443744186e35e47de5c30555
ARG DOTNET_7_RUNTIME_SHA_ARM64=e5b71578142f81809dd3e2bd5a9d673459c3f311ee095429b8e59929bd3ea17169c880113b7c86b8940c2db4bb1138f4770883456102da6b4b42ab7f0da8f8ed
ARG ASPNET_7_RUNTIME_VERSION=7.0.15
ARG ASPNET_7_RUNTIME_SHA_AMD64=8aae979c0e9c90e781b8747aba5d7e09c9a81845b936c9185dc16d519db3a4ad9e219da4bffe13476baa81c7ff3e1637e8ef031be1f9f305f7d1681568ae3aed
ARG ASPNET_7_RUNTIME_SHA_ARM64=4139d28b0c67497854794d34ec3eb3d7f4a49f34be4ed43cb634be88e7315af81090dd851fe2cdd429bf0050345f14000d2f939c020aeb809a1696483afdebe6
ARG DOTNET_6_VERSION=6.0.418
ARG DOTNET_6_SHA_AMD64=24d705157ae51ed5ec5ff267c76474d2ff71b0e56693f700de456321f15212a7791291b95770522a976434f5220e5c03b042f41755a0b6e9854abf73cd51e299
ARG DOTNET_6_SHA_ARM64=2848db109c65dc284320f680c13b498789f944f3474788548c0bf15d333020cf9b8286348bacda9af56e1dea6b56590ff24669de7ed5eaa31906f4710cabc6e1
ARG DOTNET_6_RUNTIME_VERSION=6.0.26
ARG DOTNET_6_RUNTIME_SHA_AMD64=7336f71f7f99ffc3a44c7d730c6a1e08c5c0b6e05d2076a1963776f174f8588d31c9b783d1c4f645f7e7cc6a54077b798c6bde35ed4a812ffd9b2427d29b0b34
ARG DOTNET_6_RUNTIME_SHA_ARM64=775d96bb3dfa6f5e7f81829e7eedf0744aeb75d5e1a613622debd1f285f9eda694ae79effe531558dd8367dc4fad5d682039aa24fb2bbb39fb561c67aeeb4a18
ARG ASPNET_6_RUNTIME_VERSION=6.0.26
ARG ASPNET_6_RUNTIME_SHA_AMD64=51a0091ffa5abb2a6f2f968f76848e475310fbb33126238bc1358ee86e24bfd3f046d32af2f39dc7a30b14becdd637d1314ca4f4b771fe5fa0954474a605e4fd
ARG ASPNET_6_RUNTIME_SHA_ARM64=48330ea4d98fc565c9553ea119f56e3e485ca30a0986f43e78335e263d9cc82d17b7ced8115480d1adb33298cbc5cb2b0759bc89d516659c4c59eab9520a2254

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
#     See: https://github.com/nodejs/docker-node/blob/bdf5edb771596f7e3998ff318c3098850261b17b/18/bookworm/Dockerfile
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
  4ED778F539E3634C779C87C6D7062848A1AB005C \
  141F07595B7B3FFE74309A937405533BE57C7D57 \
  74F12602B6F1C4E913FAA37AD3A89613643B6201 \
  DD792F5973C6DE52C432CBDAC77ABFA00DDBF2B7 \
  61FC681DFB92A079F1685E77973F295594EC4689 \
  8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
  C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
  C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
  108F52B48DB57BB0CC439B2997B01419BD92F80A \
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

# Install .NET 7 SDK
#   See: https://github.com/dotnet/dotnet-docker/blob/4a40f7eeecad2a3f15541fbb84962f8789d23cb0/src/sdk/7.0/bullseye-slim/amd64/Dockerfile
#        https://github.com/dotnet/dotnet-docker/blob/4a40f7eeecad2a3f15541fbb84962f8789d23cb0/src/sdk/7.0/bullseye-slim/arm64v8/Dockerfile
RUN if [ "$(dpkg --print-architecture)" = "arm64" ]; then \
  curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/${DOTNET_7_VERSION}/dotnet-sdk-${DOTNET_7_VERSION}-linux-arm64.tar.gz \
  && echo "${DOTNET_7_SHA_ARM64} dotnet.tar.gz" | sha512sum -c - ; \
  else \
  curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/${DOTNET_7_VERSION}/dotnet-sdk-${DOTNET_7_VERSION}-linux-x64.tar.gz \
  && echo "${DOTNET_7_SHA_AMD64} dotnet.tar.gz" | sha512sum -c - ; \
  fi \
  && mkdir -p /usr/share/dotnet \
  && tar -oxzf dotnet.tar.gz -C /usr/share/dotnet ./packs ./sdk ./sdk-manifests ./templates ./LICENSE.txt ./ThirdPartyNotices.txt \
  && rm dotnet.tar.gz \
  # Trigger first run experience by running arbitrary cmd
  && dotnet help


# Install .NET 7 runtime (for STS tools)
#   See: https://github.com/dotnet/dotnet-docker/blob/4a40f7eeecad2a3f15541fbb84962f8789d23cb0/src/runtime/7.0/bullseye-slim/amd64/Dockerfile
#        https://github.com/dotnet/dotnet-docker/blob/4a40f7eeecad2a3f15541fbb84962f8789d23cb0/src/runtime/7.0/bullseye-slim/arm64v8/Dockerfile
RUN if [ "$(dpkg --print-architecture)" = "arm64" ]; then \
  curl -fSL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/${DOTNET_7_RUNTIME_VERSION}/dotnet-runtime-${DOTNET_7_RUNTIME_VERSION}-linux-arm64.tar.gz \
  && echo "${DOTNET_7_RUNTIME_SHA_ARM64}  dotnet.tar.gz" | sha512sum -c - ; \
  else \
  curl -fSL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/${DOTNET_7_RUNTIME_VERSION}/dotnet-runtime-${DOTNET_7_RUNTIME_VERSION}-linux-x64.tar.gz \
  && echo "${DOTNET_7_RUNTIME_SHA_AMD64}  dotnet.tar.gz" | sha512sum -c - ; \
  fi \
  && mkdir -p /usr/share/dotnet \
  && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet \
  && rm dotnet.tar.gz \
  # Trigger first run experience by running arbitrary cmd
  && dotnet help

# Install ASP.NET Core 7 runtime (for STS tools)
#   See: https://github.com/dotnet/dotnet-docker/blob/4a40f7eeecad2a3f15541fbb84962f8789d23cb0/src/aspnet/7.0/bullseye-slim/amd64/Dockerfile
#        https://github.com/dotnet/dotnet-docker/blob/4a40f7eeecad2a3f15541fbb84962f8789d23cb0/src/aspnet/7.0/bullseye-slim/arm64v8/Dockerfile
RUN if [ "$(dpkg --print-architecture)" = "arm64" ]; then \
  curl -fSL --output aspnetcore.tar.gz https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/${ASPNET_7_RUNTIME_VERSION}/aspnetcore-runtime-${ASPNET_7_RUNTIME_VERSION}-linux-arm64.tar.gz \
  && echo "${ASPNET_7_RUNTIME_SHA_ARM64}  aspnetcore.tar.gz" | sha512sum -c - ; \
  else \
  curl -fSL --output aspnetcore.tar.gz https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/${ASPNET_7_RUNTIME_VERSION}/aspnetcore-runtime-${ASPNET_7_RUNTIME_VERSION}-linux-x64.tar.gz \
  && echo "${ASPNET_7_RUNTIME_SHA_AMD64}  aspnetcore.tar.gz" | sha512sum -c - ; \
  fi \
  && mkdir -p /usr/share/dotnet \
  && tar -ozxf aspnetcore.tar.gz -C /usr/share/dotnet \
  && rm aspnetcore.tar.gz \
  # Trigger first run experience by running arbitrary cmd
  && dotnet help

# Install .NET 6 SDK
#   See: https://github.com/dotnet/dotnet-docker/blob/865bcccb010b1a703c23d584153f1168754dc42e/src/sdk/6.0/bullseye-slim/amd64/Dockerfile
#        https://github.com/dotnet/dotnet-docker/blob/865bcccb010b1a703c23d584153f1168754dc42e/src/sdk/6.0/bullseye-slim/arm64v8/Dockerfile
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
#   See: https://github.com/dotnet/dotnet-docker/blob/865bcccb010b1a703c23d584153f1168754dc42e/src/runtime/6.0/bullseye-slim/amd64/Dockerfile
#        https://github.com/dotnet/dotnet-docker/blob/865bcccb010b1a703c23d584153f1168754dc42e/src/runtime/6.0/bullseye-slim/arm64v8/Dockerfile
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
#   See: https://github.com/dotnet/dotnet-docker/blob/865bcccb010b1a703c23d584153f1168754dc42e/src/aspnet/6.0/bullseye-slim/amd64/Dockerfile
#   See: https://github.com/dotnet/dotnet-docker/blob/865bcccb010b1a703c23d584153f1168754dc42e/src/aspnet/6.0/bullseye-slim/arm64v8/Dockerfile
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
