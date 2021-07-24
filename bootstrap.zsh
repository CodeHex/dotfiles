#!/bin/zsh

# Import bootstrapping functions
. ./.functions --source-only

# Configure current run
. ./.env

# Create default development folder
mkdir -p "~/dev"

update_mac_osx_software

# Detect if the homebrew command is available, if not install homebrew otherwise update it
if [[ $(command -v brew) == "" ]]; then
	install_homebrew
else
	update_homebrew
fi

update_homebrew_bundle

update_config_file .gitconfig ~/.gitconfig

# Generate GPG key if one is not detected
if ! git config --global user.signingkey > /dev/null; then 
	generate_gpg_key_for_github
fi

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

# Configure MacOSX settings
if [[ $CONFIGURE_MAC == "true" ]]; then
	. ./.macosx
fi

SOURCE_ZSH=0
update_config_file .zprofile ~/.zprofile && SOURCE_ZSH=1
update_config_file .aliases ~/.aliases && SOURCE_ZSH=1
update_config_file .zshrc ~/.zshrc && SOURCE_ZSH=1
update_config_file powerline_config ~/.config/powerline && . /opt/homebrew/lib/python3.9/site-packages/powerline/bindings/zsh/powerline.zsh

if update_config_file gpg-agent.conf ~/.gnupg/gpg-agent.conf; then
	restart_gpg_agent
fi

update_config_file vscode/vscode_settings.json "${HOME}/Library/Application Support/Code/User/settings.json"

update_vscode_exts
upgrade_node

log_ok "🎉 Bootstrap complete!"
if [ "$SOURCE_ZSH" = '1' ]; then
    log_warn "⚠️  Please run 'source ~/.zshrc' to load recent changes"
fi
