####
#  ci-env-dotnet
#    Continuous integration environment based upon .NET SDK ('current' support level image).
#    Additional SDKs:
#      .NET Core (all currently-supported .NET Core 'LTS' support level SDKs)
#      node.js (current LTS support level release).
####
ARG DOTNET_SDK_IMAGE=mcr.microsoft.com/dotnet/sdk:8.0.201

# https://hub.docker.com/_/microsoft-dotnet
# https://hub.docker.com/_/microsoft-dotnet-aspnet/
# https://hub.docker.com/_/microsoft-dotnet-runtime/
# https://hub.docker.com/_/microsoft-dotnet-sdk/
# https://hub.docker.com/_/node/
FROM ${DOTNET_SDK_IMAGE} AS build-environment

ARG NODE_VERSION=18.19.1
ARG DOTNET_7_VERSION=7.0.406
ARG DOTNET_7_SHA_AMD64=5455ac21b1d8a37da326b99128a7d10983673259f4ccf89b7cdc6f67bb5f6d4f123caadb9532d523b2d9025315e3de684a63a09712e2dc6de1702f5ad1e9c410
ARG DOTNET_7_SHA_ARM64=7543ab3197653864aa72c2f711e0661a881d7c74ef861fb1e952b15b7f8efd909866e99ea0e43430768db223b79d4e0285f3114087b6e009b5d382b4adad13fc
ARG DOTNET_7_RUNTIME_VERSION=7.0.16
ARG DOTNET_7_RUNTIME_SHA_AMD64=e1eae1aae9088e8131317e217f4cd3059628cce847103775c61c2d641d19486168bede5fe3123668f81f35bdc5a41100cbb49126d55445e7f5c5c617e2ca3b49
ARG DOTNET_7_RUNTIME_SHA_ARM64=4a38d656e22129605a5f156b61098f6eb598a88e1d6248577d064481e7f4632fecf9bb60580c266347b4ee60133a617a5528aa6fc789faee83e5cca5fba884c2
ARG ASPNET_7_RUNTIME_VERSION=7.0.16
ARG ASPNET_7_RUNTIME_SHA_AMD64=1482c7c946c1b1a0a39f2bef4eaceed0a9b9eae44d3e8a103e6574b64391749d163ad4d65198573571885906215078ff41f53ebfc7884aa8a437c527532521f4
ARG ASPNET_7_RUNTIME_SHA_ARM64=9acc4c8e99d9ff50f3f5e5615e25e30561a8475ca66332bcb93d3305aa68f1bfb142d21c3eb7cd07627c15d2e3abcfd4d504db617e7c662b83e2b76e4019b3d4
ARG DOTNET_6_VERSION=6.0.419
ARG DOTNET_6_SHA_AMD64=155a9ab33dc11a76502c24b94dbcd188b06e51f56814082f6570fd923cd74b0266baefbcb6becdd34e41c3979f5b21ca333a7fa57f0e41e5435d28e8815d1641
ARG DOTNET_6_SHA_ARM64=c249e5c1d15f040e2e4ce444328ec30dd1097984b1b0c4d48d1beb61c7e35d06f133509500ee63ded86a420e569920809b587ff2abe073da3d8f10d4a03a9d15
ARG DOTNET_6_RUNTIME_VERSION=6.0.27
ARG DOTNET_6_RUNTIME_SHA_AMD64=448c4419e6c5b52e82eebaaf8601bbe668a0c8bb3293a6004125c7305b38072f7d2236ebffcaf4a71901b61b22ce66ae8b077af6321ba14729be385f228be04c
ARG DOTNET_6_RUNTIME_SHA_ARM64=2e9772089ca8d548201d02542ba2013506530183ea6f52e8907afa608662ae967579add6d9704b75c22f2639667ef87682a7ce92aff05d51670e9354e52df1ee
ARG ASPNET_6_RUNTIME_VERSION=6.0.27
ARG ASPNET_6_RUNTIME_SHA_AMD64=47495e387c63b10f3b52065f40738d58b5b60d260d23cff96fe6beeb290f2f329a538c8065443fa3b10ecbd3456bdae58e443118870e7b5774210caf07c3f688
ARG ASPNET_6_RUNTIME_SHA_ARM64=cafb52efb2bb646459c3d133a6968105867bbe0ef580318def47ff83770e1f180431f53c5a7899563b5c8d7fe44a58d423c8c7a4b3f29054010230fb47b1fa89

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
