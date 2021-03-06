# ci-env-dotnet

Repository supporting `gnosian/ci-env-dotnet` [Docker repository][repository]. Defines a continuous integration environment, based on .NET SDK images, with additional tools and SDKs.

## Included SDKs

* .NET SDK
  * `Current` version and all currently-supported `LTS` versions.
  * Currently: `5.0.401`
* .NET Core SDK
  * All currently-supported `LTS` versions.
  * Currently: `3.1.413`
* node.js
  * Current `LTS` version.
  * Currently: `14.17.6`

## Included Shells

* `bash` (Provided by base .NET image)
  * GNU bash, version `5.0.3(1)-release` (as of 2021/06/27)
* `pwsh` (Provided by base .NET image)
  * PowerShell `7.1.4` (as of 2021/09/18)
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

[aws-cli]: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html
[cdk]: https://docs.aws.amazon.com/cdk/latest/guide/getting_started.html
[cicee]: https://github.com/JeremiahSanders/cicee
[cicee-lib]: https://github.com/JeremiahSanders/cicee/blob/dev/docs/use/ci-library.md
[coverlet]: https://github.com/coverlet-coverage/coverlet/blob/master/Documentation/GlobalTool.md
[docker]: https://docs.docker.com/engine/reference/commandline/cli/
[fantomas]: https://github.com/fsprojects/fantomas/blob/master/docs/Documentation.md#using-the-command-line-tool
[jq]: https://stedolan.github.io/jq/
[repository]: https://hub.docker.com/r/gnosian/ci-env-dotnet
[resharper-tools]: https://www.jetbrains.com/help/resharper/ReSharper_Command_Line_Tools.html
[typescript]: https://www.typescriptlang.org/
[zip]: https://linux.die.net/man/1/zip
