#!/bin/zsh

. ./functions.zsh --source-only

update_mac_osx_software
update_homebrew
update_homebrew_bundle

update_config_file .gitconfig ~/.gitconfig
update_config_file .ssh_config ~/.ssh/config
update_config_file .zprofile ~/.zprofile
update_config_file .zshrc ~/.zshrc
update_config_file powerline_config ~/.config/powerline

if update_config_file gpg-agent.conf ~/.gnupg/gpg-agent.conf; then
	log_info " - restarting gpg agent"
	gpg-connect-agent reloadagent /bye
fi

update_config_file vscode/vscode_settings.json "${HOME}/Library/Application Support/Code/User/settings.json"

update_vscode_exts
upgrade_node

source ~/.zshrc

log_ok "🎉 Update complete!"
