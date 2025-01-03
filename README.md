# ci-env-dotnet

Repository supporting `gnosian/ci-env-dotnet` [Docker repository][repository]. Defines a continuous integration environment, based on .NET SDK images, with additional tools and SDKs.

## Included SDKs

* .NET SDK
  * `Current` (`STS`) version and all [currently-supported][dotnet-support-policy] `LTS` versions.
  * Currently: `9.0.101` (`STS`); `8.0.404` (`LTS`); `6.0.427` (`LTS`)
* node.js
  * Current `LTS` version.
  * Currently: `20.18.1` (includes `npm` `10.8.2`)

## Included Shells

* `bash` (Provided by base .NET image)
  * GNU bash, version `5.2.15(1)-release` (as of 2024/11/20)
* `pwsh` (Provided by base .NET image)
  * PowerShell `7.5.0-preview.5` (as of 2024/11/20)
* `sh` (Provided by base .NET image)

## Included Tools

> The following tools are installed with no explicit version requirement.

| Name                                      | CLI command | Description                                                            |
| ----------------------------------------- | ----------- | ---------------------------------------------------------------------- |
| [AWS CDK CLI][cdk]                        | `cdk`       | Enables creation and deployment of AWS infrastructure-as-code.         |
| [AWS CLI][aws-cli]                        | `aws`       | Enables interaction with AWS infrastructure.                           |
| [CICEE][cicee]                            | `cicee`     | Provides a continuous integration [shell function library][cicee-lib]. |
| [Coverlet][coverlet]                      | `coverlet`  | Enables .NET test coverage analysis.                                   |
| [Docker CLI][docker]                      | `docker`    | Enables Docker support.                                                |
| [Fantomas][fantomas]                      | `fantomas`  | Enables F# linting and formatting.                                     |
| [jq][]                                    | `jq`        | Enables parsing JSON.                                                  |
| [ReSharper Global Tools][resharper-tools] | `jb`        | Enables C# linting and other continuous integration tasks.             |
| [TypeScript][typescript]                  |             | Enables TypeScript language support in node.js.                        |
| [zip][]                                   | `zip`       | Enables compressing build artifacts.                                   |

> **Docker CLI Note**: `docker` CLI is provided by Debian's `docker.io` (not `docker-ce-cli`).
>
> **ARM64 Note**: .NET global tools are **not** installed on ARM64 images, due to unresolved `dotnet tool install --global` errors. The following tools listed above are not available on ARM64: `cicee`, `coverlet`, `fantomas`, and `jb`. Projects using those tools in ARM64 environments must install them as .NET local tools, if possible.
>
> **Git Note**: This image includes `/code` in its global Git configuration `safe.directory`. (Required to enable [`cicee`][cicee] continuous integration scripts to generate prerelease versions for your code when using `cicee lib exec` within a `cicee exec` environment, which mounts your project code to `/code`.) This image _does not_ initialize the `/code` directory, so this should not be a security concern. However, if you wish to _disable_ this Git safe directory registration when building an image based upon this image, add a `RUN` layer to your `Dockerfile` which [sets the `safe.directory` as shown in Git documentation][git-safe-directory].

[aws-cli]: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html
[cdk]: https://docs.aws.amazon.com/cdk/latest/guide/getting_started.html
[cicee]: https://github.com/JeremiahSanders/cicee
[cicee-lib]: https://github.com/JeremiahSanders/cicee/blob/dev/docs/use/ci-library.md
[coverlet]: https://github.com/coverlet-coverage/coverlet/blob/master/Documentation/GlobalTool.md
[docker]: https://docs.docker.com/engine/reference/commandline/cli/
[dotnet-support-policy]: https://dotnet.microsoft.com/platform/support/policy/dotnet-core
[fantomas]: https://github.com/fsprojects/fantomas/blob/master/docs/Documentation.md#using-the-command-line-tool
[git-safe-directory]: https://git-scm.com/docs/git-config#Documentation/git-config.txt-safedirectory
[jq]: https://stedolan.github.io/jq/
[repository]: https://hub.docker.com/r/gnosian/ci-env-dotnet
[resharper-tools]: https://www.jetbrains.com/help/resharper/ReSharper_Command_Line_Tools.html
[typescript]: https://www.typescriptlang.org/
[zip]: https://linux.die.net/man/1/zip
