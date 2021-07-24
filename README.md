# dotfiles

Bootstraps a new Mac in minutes. Designed to be run repeatedly to manage installed software and config files.

## Installation

Clone the repo and navigate to the root folder

```bash
git clone https://github.com/codehex/dotfiles.git && cd dotfiles
```

Add an `.env` file containing
```bash
# Sets MacOSX settings, causes Finder and Dock to reboot
# Set to false if MacOSX settings have been applied
export CONFIGURE_MAC="true"  

# Git settings
export GIT_NAME="<name>"
export GIT_EMAIL="<email_address>"
export GIT_USERNAME="<git_username>"
export GIT_SIGNING_KEY="<gpg_key_id>"
``` 

## Usage

Run `bootstrap.zsh` to bootstrap a new Mac machine, can be run frequently to keep software and config files up to date.
```bash
./bootstrap.zsh
```

Run `update.zsh` to run a slimline version of `bootstrap.zsh` for Macs that have already been bootstrapped previously.
```bash
./update.zsh
```
Update `Brewfile` to control which software to install via Homebrew

## Reference

The scripts perform the following operations

### bootstrap.zsh
- **Update MacOSX software** - Runs the software update tool, providing an user option to install any new updates. May cause reboots.
- **Installs/Updates [Homebrew](https://brew.sh/)** - Ensures Homebrew is installed and updates all installed software via Homebrew.
- **Updates [Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle)** - Installs or removes software based on the [Brewfile](Brewfile) in the root directory.
- **Setup `.gitconfig` file**
- **Generate GPG key for signing git commits** - Checks if a signing key has been configure for git. If not, walks the user through the process of generating a GPG key and configuring it for Github.
- **Setup `.sshconfig` file**
- **Generate SSH key for Github** - Checks if an SSH key is already present (`~/.ssh/id_ed25519`). If not, walks the user through the process of generating an SSH key and configuing it for Github.
- **Installs [Oh My ZSH](https://ohmyz.sh/)** - Checks if the `~/.zshrc` file exists, and if not installs Oh My ZSH.
- **Installs [Powerline](https://github.com/powerline/powerline)** - Detects if Powerline is installed and installs it if not.
- **Configure MacOSC settings** - Applies MacOSX system settings defined in `.macosx`. Can be turned on and off via the `.env` file.
- **Setup `.zprofile`, `aliases` and `.zshrc` files** - Configure ZSH shell
- **Setup `.powerline_config` files** - Configures Powerline settings and theme.
- **Setup `gpg-agent.conf` file** - Ensures GPG key is cached for a long time.
- **Setup `vscode_settings.json` file** - Configures VSCode settings
- **Updates VSCode extensions** - Ensures that all VSCode extension in `vscode/vscode_extensions.txt` are installed. Does not remove extension that are not on the list.
- **Install/Upgrade Node** - Detects and updates to the latest version of Node.

### update.zsh
- **Update MacOSX software** - Runs the software update tool, providing an user option to install any new updates. May cause reboots.
- **Updates [Homebrew](https://brew.sh/)** - Updates Homebrew formulae and upgrades all installed software via Homebrew.
- **Updates [Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle)** - Installs or removes software based on the [Brewfile](Brewfile) in the root directory.
- **Setup `.gitconfig` and `.sshconfig` files**
- **Setup `.zprofile`, `aliases` and `.zshrc` files** - Configure ZSH shell
- **Setup `.powerline_config` files** - Configures Powerline settings and theme.
- **Setup `vscode_settings.json` file** - Configures VSCode settings
- **Updates VSCode extensions** - Ensures that all VSCode extension in `vscode/vscode_extensions.txt` are installed. Does not remove extension that are not on the list.
- **Install/Upgrade Node** - Detects and updates to the latest version of Node.

## Disclaimer

**WARNING-Use these files at your own risk** - These files have only been tested on my machine. If you would like to use these files, please review the contents of the scripts, remove anything you don't want or need and ensure you understand what these scripts are doing. Thank you. 
