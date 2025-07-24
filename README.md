# Niks

❄️ Niks is unified configuration of devices owned by [`@keinsell`](https://github.com/keinsell) to avoid pain in managing and syncing dotfiles and security configurations. Including NixOS, Linux and MacOS.

## Getting Started

*For the convinient setup of new machines repository contains installation script `install` at the root of this repository*

### Installation

Even through repository is using (experimental) Flakes you should remember that [flakes aren't real and cannot hurt you](https://jade.fyi/blog/flakes-arent-real/). Instllation process is explained from scratch as this repository is meant to configure operating system from scratch.

#### Install Nix

Install Nix with Determinate Systems's installer.

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm --extra-conf "trusted-users = $(whoami)"
```

#### Activating NixOS or nix-darwin configurations

In order to activate a system configuration for the current host ($HOSTNAME), run:

```bash
nix run .#activate
```

#### Activating home configuration

If you are on a non-NixOS Linux (or on macOS but you do not use nix-darwin), you will have a home-manager configuration. Suppose, you have it stored in legacyPackages.homeConfigurations."myuser" (where myuser matches $USER), you can activate that by running:

```bash
nix run .#activate $USER@
```

## Features

### Shell Configuration

- `nushell` and `zsh` configurations.


### Version Control

#### Git Credential Manager (GCM)

Configuration uses [Git Credential Manager (GCM)](https://microsoft.github.io/Git-Credential-Manager-for-Windows/Docs/CredentialManager.html) for Linux credentials handling along with `secretservice` for storing credentials in the system keyring, for macOS it uses native keychain.

#### PGP Commit Signing Integration (TODO)
