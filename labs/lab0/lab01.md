## Install tooling for AWS CloudShell
This workshop leverages several tools and technologies.
| Artifact/Action | Purpose | Pre-Install in CloudShell |
|---|---|---|
| kubectl | `kubectl` command line tool | Yes |
| kubectl Bash Completion | Bash completion for `kubectl` | Yes |
| aws cli | AWS Command Line tool | Yes |
| terraform | Install terraform | No |
> [!TIP]
> The directions in this module of this workshop assume you're running it on a AWS CloudShell. Though most of it could probably run on Mac or Windows (WSL), it has not been tested nor documented.

The setup.sh script takes care of installing the tools and dependencies that are not installed on AWS CloudShell. 

Let's run that script to install them:
```bash
sh ./scripts/setup.sh
```

