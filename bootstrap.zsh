#!/bin/zsh

. ./functions.zsh --source-only

# Configure current run
CONFIGURE_MAC="false"
NODE_VERSION="16.4.2"    # Use `nodenv install -l` to view all available versions and update this variable

# Create default development folder
mkdir -p /Users/ben/dev

update_mac_osx_software

# Detect if the homebrew command is available, if not install homebrew otherwise update it
if [[ $(command -v brew) == "" ]]; then
	install_homebrew
else
	update_homebrew
fi

update_homebrew_bundle

# Generate GPG key if one is not detected
if ! git config --global user.signingkey > /dev/null; then 
	generate_gpg_key_for_github
fi

update_config_file .gitconfig ~/.gitconfig
update_config_file .ssh_config ~/.ssh/config

# Generate SSH key if one is not detected
if [[ ! -f ~/.ssh/id_ed25519 ]]; then
	generate_ssh_key_for_github
fi

# Install Oh My Zsh if the .zshrc file is not detected
if [[ ! -f ~/.zshrc ]]; then
	install_oh_my_zsh
fi

# Install powerline if the plugin is not already installed via pip
if ! echo $(pip3 list) | grep -q "powerline-status"; then
	install_powerline
fi

# Reload the terminal incase any files are updated
update_config_file .zprofile ~/.zprofile
update_config_file .zshrc ~/.zshrc
update_config_file powerline_config ~/.config/powerline
update_config_file gpg-agent.conf ~/.gnupg/gpg-agent.conf
source ~/.zshrc


if [[ $CONFIGURE_MAC == "true" ]]; then
	configure_mac
fi

update_config_file vscode/vscode_settings.json "${HOME}/Library/Application Support/Code/User/settings.json"

update_vscode_exts
install_node $NODE_VERSION

log_ok "🎉 Bootstrap complete!"
