####
#  ci-env-dotnet
#    Continuous integration environment based upon .NET SDK ('current' support level image).
#    Additional SDKs:
#      .NET Core (all currently-supported .NET Core 'LTS' support level SDKs)
#      node.js (current LTS support level release).
####
ARG DOTNET_SDK_IMAGE=mcr.microsoft.com/dotnet/sdk:5.0.202

# https://hub.docker.com/_/microsoft-dotnet
FROM ${DOTNET_SDK_IMAGE} AS build-environment

ARG NODE_VERSION=14.16.0
ARG DOTNETCORE_31_VERSION=3.1.407
ARG DOTNETCORE_31_SHA=b9c61061464a38df0a3eb5894a4a1229cd27d2ccba4168e434f4609b763630c01fbe1b2564826194d6d9b5ad86047e586312c0f35eafc3755dfe0ff9ba075c0c
ARG DOTNETCORE_21_VERSION=2.1.814
ARG DOTNETCORE_21_SHA=79408996f53650d0c3ac39348fa102537d14190ba5dcc4b9152cdb8fc72566608ad7430f196731eeb62dcfacdb0f2fa37577b5d51e165afd9dd9ae15f9d2aabc

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
#     See: https://github.com/nodejs/docker-node/blob/6e7d6511aba22da645ec21bd157a369a78794e6c/14/stretch/Dockerfile
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
  94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
  74F12602B6F1C4E913FAA37AD3A89613643B6201 \
  71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
  8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
  C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
  DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
  A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
  108F52B48DB57BB0CC439B2997B01419BD92F80A \
  B9E2F5981AA6E0CD28160D9FF13993A75599653C \
  ; do \
  gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
  gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
  gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
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

# Install .NET Core 3.1 SDK - To support 3.1 LTS projects and 3.1 tools, e.g., JetBrains 'jb'.
#   See: https://github.com/dotnet/dotnet-docker/blob/c0d0ee41932ff30f1eb2e9a1dd0faf92b3dceb9c/src/sdk/3.1/buster/amd64/Dockerfile
RUN curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/${DOTNETCORE_31_VERSION}/dotnet-sdk-${DOTNETCORE_31_VERSION}-linux-x64.tar.gz \
  && echo "${DOTNETCORE_31_SHA} dotnet.tar.gz" | sha512sum -c - \
  && mkdir -p /usr/share/dotnet \
  && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet \
  && rm dotnet.tar.gz

# Install .NET Core 2.1 SDK - To support 2.1 LTS projects and 2.1 tools, e.g., fantomas.
#   See: https://github.com/dotnet/dotnet-docker/blob/c0d0ee41932ff30f1eb2e9a1dd0faf92b3dceb9c/src/sdk/2.1/stretch/amd64/Dockerfile
RUN curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/${DOTNETCORE_21_VERSION}/dotnet-sdk-${DOTNETCORE_21_VERSION}-linux-x64.tar.gz \
  && echo "${DOTNETCORE_21_SHA} dotnet.tar.gz" | sha512sum -c - \
  && mkdir -p /usr/share/dotnet \
  && tar -zxf dotnet.tar.gz -C /usr/share/dotnet \
  && rm dotnet.tar.gz

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
