#!/bin/zsh

. ./.env
. ./.functions --source-only

update_mac_osx_software
update_homebrew
update_homebrew_bundle

update_git_config
update_config_file .ssh_config ~/.ssh/config

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
upgrade_ruby
upgrade_terraform

log_ok "🎉 Update complete!"
if [ "$SOURCE_ZSH" = '1' ]; then
    echo "source ~/.zshrc" | pbcopy
    log_warn "⚠️  Please run 'source ~/.zshrc' (copied to clipboard) to load recent changes"
fi
