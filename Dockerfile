####
#  ci-env-dotnet
#    Continuous integration environment based upon .NET SDK ('current' support level image).
#    Additional SDKs:
#      .NET Core (all currently-supported .NET Core 'LTS' support level SDKs)
#      node.js (current LTS support level release).
####
ARG DOTNET_SDK_IMAGE=mcr.microsoft.com/dotnet/sdk:7.0.403

# https://hub.docker.com/_/microsoft-dotnet
# https://hub.docker.com/_/microsoft-dotnet-aspnet/
# https://hub.docker.com/_/microsoft-dotnet-runtime/
# https://hub.docker.com/_/microsoft-dotnet-sdk/
FROM ${DOTNET_SDK_IMAGE} AS build-environment

ARG NODE_VERSION=18.16.0
ARG DOTNET_6_VERSION=6.0.413
ARG DOTNET_6_SHA=ee0a77d54e6d4917be7310ff0abb3bad5525bfb4beb1db0c215e65f64eb46511f5f12d6c7ff465a1d4ab38577e6a1950fde479ee94839c50e627020328a702de
ARG DOTNET_6_RUNTIME_VERSION=6.0.21
ARG DOTNET_6_RUNTIME_SHA=9b1573f7a42d6c918447b226fda4173b7db891a7290b51ce36cf1c1583f05643a3dda8a13780b5996caa2af36719a910377e71149f538a6fa30c624b8926e0cd
ARG ASPNET_6_RUNTIME_VERSION=6.0.21
ARG ASPNET_6_RUNTIME_SHA=3a74b52e340653822ad5120ec87e00e4bc0217e8ce71020ad9c4a0903b87d221b538c3841949be2ca129a45f8105def0ea5152e44e7cef8858958ae04fa0dd65

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
#     See: https://github.com/nodejs/docker-node/blob/4c95f887f7863eccc17d66729cd24ecc230209a2/18/bullseye/Dockerfile
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
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
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
  && rm -rf /var/lib/apt/lists/*

# Install .NET 6 SDK
#   See: https://github.com/dotnet/dotnet-docker/blob/b5386162bf4ccc311b70fa97b3217e073fb8eca2/src/sdk/6.0/bullseye-slim/amd64/Dockerfile
RUN curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/${DOTNET_6_VERSION}/dotnet-sdk-${DOTNET_6_VERSION}-linux-x64.tar.gz \
  && echo "${DOTNET_6_SHA} dotnet.tar.gz" | sha512sum -c - \
  && mkdir -p /usr/share/dotnet \
  && tar -oxzf dotnet.tar.gz -C /usr/share/dotnet ./packs ./sdk ./sdk-manifests ./templates ./LICENSE.txt ./ThirdPartyNotices.txt \
  && rm dotnet.tar.gz \
  # Trigger first run experience by running arbitrary cmd
  && dotnet help

# Install .NET 6 runtime (for LTS tools)
#   See: https://github.com/dotnet/dotnet-docker/blob/9b731e901dd4a343fc30da7b8b3ab7d305a4aff9/src/runtime/6.0/bullseye-slim/amd64/Dockerfile
RUN curl -fSL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/${DOTNET_6_RUNTIME_VERSION}/dotnet-runtime-${DOTNET_6_RUNTIME_VERSION}-linux-x64.tar.gz \
  && echo "${DOTNET_6_RUNTIME_SHA}  dotnet.tar.gz" | sha512sum -c - \
  && mkdir -p /usr/share/dotnet \
  && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet \
  && rm dotnet.tar.gz \
  # Trigger first run experience by running arbitrary cmd
  && dotnet help

# Install ASP.NET Core 6 runtime (for LTS tools)
#   See: https://github.com/dotnet/dotnet-docker/blob/9b731e901dd4a343fc30da7b8b3ab7d305a4aff9/src/aspnet/6.0/bullseye-slim/amd64/Dockerfile
RUN curl -fSL --output aspnetcore.tar.gz https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/${ASPNET_6_RUNTIME_VERSION}/aspnetcore-runtime-${ASPNET_6_RUNTIME_VERSION}-linux-x64.tar.gz \
  && echo "${ASPNET_6_RUNTIME_SHA}  aspnetcore.tar.gz" | sha512sum -c - \
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
RUN  dotnet tool install --global cicee \
  && dotnet tool install --global coverlet.console \
  && dotnet tool install --global fantomas-tool \
  && dotnet tool install --global JetBrains.ReSharper.GlobalTools
