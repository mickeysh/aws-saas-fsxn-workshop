## Install tooling for AWS CloudShell
This workshop leverages several tools and technologies. The setup.sh script takes care of installing those tools and dependencies. Below is a list of the artifacts installed and actions by the setup script:
> [!TIP]
> The directions in this module of this workshop assume you're running it on a AWS CloudShell. Though most of it could probably run on Mac or Windows (WSL), it has not been tested nor documented.
---
| Artifact/Action | Purpose |
|---|---|
| kubectl | Installs `kubectl` command line tool |
| kubectl Bash Completion | Installs bash completion for `kubectl` |
| eksctl | Installs `eksctl` command line tool |
| terraform | Install terraform |

Let's run that script now:
```bash
sh ./scripts/setup.sh
```

