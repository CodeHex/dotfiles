#!/bin/zsh

. ./functions.zsh --source-only

update_mac_osx_software
update_homebrew
update_homebrew_bundle

update_config_file .zprofile ~/.zprofile
update_config_file .zshrc ~/.zshrc
update_config_file powerline_config ~/.config/powerline

update_config_file .gitconfig ~/.gitconfig
update_config_file .ssh_config ~/.ssh/config
update_config_file vscode_settings.json "${HOME}/Library/Application Support/Code/User/settings.json"
update_vscode_exts

source ~/.zshrc

log_ok "🎉 Update complete!"
