####
#  ci-env-dotnet
#    Continuous integration environment based upon .NET SDK ('current' support level image).
#    Additional SDKs:
#      .NET Core (all currently-supported .NET Core 'LTS' support level SDKs)
#      node.js (current LTS support level release).
####
ARG DOTNET_SDK_IMAGE=mcr.microsoft.com/dotnet/sdk:9.0.100

# https://hub.docker.com/_/microsoft-dotnet
# https://hub.docker.com/_/microsoft-dotnet-aspnet/
# https://hub.docker.com/_/microsoft-dotnet-runtime/
# https://hub.docker.com/_/microsoft-dotnet-sdk/
# https://hub.docker.com/_/node/
FROM ${DOTNET_SDK_IMAGE} AS build-environment

ARG NODE_VERSION=20.18.1

# https://github.com/dotnet/dotnet-docker/blob/main/README.sdk.md#full-tag-listing
ARG DOTNET_6_VERSION=6.0.427
ARG DOTNET_6_SHA_AMD64=a9cd1e5ccc3c5d847aca2ef21dd145f61c6b18c4e75a3c2fc9aed592c6066d511b8b658c54c2cd851938fe5aba2386e5f6f51005f6406b420110c0ec408a8401
ARG DOTNET_6_SHA_ARM64=9129961b54ad77dac2b4de973875f7acd1e8d2833673a51923706620e0c5b7b8c5b057c8d395532ad9da46b1dcb5ab8fd07a4f552bd57256d5a0c21070ad5771
# https://github.com/dotnet/dotnet-docker/blob/main/README.runtime.md#full-tag-listing
ARG DOTNET_6_RUNTIME_VERSION=6.0.35
ARG DOTNET_6_RUNTIME_SHA_AMD64=d8d10d600fb664336949576f8ec0534dbffd573f754b9e741f20812221fafcac5f509a7e1ab44e9e63fc31a7b5dbcb19e4ec1930ffd29312212dc7454977090e
ARG DOTNET_6_RUNTIME_SHA_ARM64=945e24f9c2d677e65fddaa06cafe8d518ee599ce98883b60fd9d734320fa2f3e1ccbfb46ea26ee925e319fb5430c2e18d64269fdae96030169c4b6d3d811ea77
# https://github.com/dotnet/dotnet-docker/blob/main/README.aspnet.md#full-tag-listing
ARG ASPNET_6_RUNTIME_VERSION=6.0.35
ARG ASPNET_6_RUNTIME_SHA_AMD64=d86da938338a6d97250436d49340e8f114c05b46512ca562aadca6f3e77403d36468d3f34ed5f2d935c070f9e14aedf7299f5a03d2964dbd6576b9a2d3e776e8
ARG ASPNET_6_RUNTIME_SHA_ARM64=c949fd1b9efe9231e4c6e006ef3c4a5aedc1d4ce64ca9bc1cd52f1ce9884ea23837b49f1e6a7ab4b6df0c6f60a32573e2aefde4e14f205812d004b7b9ebe0f76

# https://github.com/dotnet/dotnet-docker/blob/main/README.sdk.md#full-tag-listing
ARG DOTNET_8_VERSION=8.0.404
ARG DOTNET_8_SHA_AMD64=2f166f7f3bd508154d72d1783ffac6e0e3c92023ccc2c6de49d22b411fc8b9e6dd03e7576acc1bb5870a6951181129ba77f3bf94bb45fe9c70105b1b896b9bb9
ARG DOTNET_8_SHA_ARM64=d147ca2e6aad8bc751b522ae91399e0e3867c42d17f892e23c8dd086ab6ccb0c13319d9b89c024b5a61ffb298e95bcfc82d9256074ddace882145c9d5a4be071
# https://github.com/dotnet/dotnet-docker/blob/main/README.runtime.md#full-tag-listing
ARG DOTNET_8_RUNTIME_VERSION=8.0.11
ARG DOTNET_8_RUNTIME_SHA_AMD64=71ea528900c6fc7b54e951622296421d2a96191870c47e937117b84b28f91bf407d02046ddfecfe4ac37dc6182c65d1940927c33e45fa3d6f0179f81692490d6
ARG DOTNET_8_RUNTIME_SHA_ARM64=f27d66dcdd249a6a2f87241b460238960240d163ffc081d8e7b42bd62702079f1a6784e3503dbd4ea8f9e816d82142fc829c759cbf9a1682b0340f0cebe16db5
# https://github.com/dotnet/dotnet-docker/blob/main/README.aspnet.md#full-tag-listing
ARG ASPNET_8_RUNTIME_VERSION=8.0.11
ARG ASPNET_8_RUNTIME_SHA_AMD64=e7acf9dc5cfa49aa7ec30dbb9586bc7beaac9e3116c75303b511770e3597b209739f28c754b2107c0255acac90187cd1000c1ee772463fc828934a4dda35f5c3
ARG ASPNET_8_RUNTIME_SHA_ARM64=75b5888b7d65cf9e971925e48962c0822f630390a3f0f04ce1d84546990fed312e8ae8513c82caeada145c2ac8de2b229fd1dad2d2df36c8e9db0df9f65595ac

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
