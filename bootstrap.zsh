#!/bin/zsh

function log_ok { print -P "%F{green}$1%f"; }
function log_warn { print -P "%F{yellow}$1%f"; }
function log_info { print -P "%F{cyan}$1%f"; }
function log_err { print -P "%F{red}$1%f"; }

function updatemac {
	log_ok "💻 Updating Mac OSX software..."
	if softwareupdate -l 2>&1 | grep -q 'No new software available.'; then
		log_info "no new software to install"
	else
		softwareupdate -l
		log_ok "\nupdate all? %F{blue}(y/n)%f"
		read -sk1
		if [[ $REPLY == "y" ]] then
				softwareupdate -ia
				log_ok "✅ Mac software updated"
		else
				log_warn "⚠️  Skipping softwate updates"
		fi
	fi
}

function installvscodeext {
	if echo $2 | grep -q $1; then
		log_info " - $1 already installed, skipping"
	else
		code --install-extension $1
	fi
}

# Configure current run
CONFIGURE_MAC="false"
NODE_VERSION="16.4.2"

# Update mac software
updatemac

# Install homebrew
if [[ $(command -v brew) == "" ]]; then
	log_ok "🍺 Installing Hombrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	
	# Add Homebrew to PATH
	echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/ben/.zprofile

	# Add autocomplete
	echo 'FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH' >> /Users/ben/.zprofile
	
	eval "$(/opt/homebrew/bin/brew shellenv)"

	# Disable analytics
	brew analytics off
else
	log_ok "🍺 Updating Homebrew..."
	brew update
	brew doctor
	brew cleanup
	brew upgrade
fi
log_ok "✅ Homebrew installed and up to date"



# Install apps under homebrew
log_ok "🍺 Running brew bundle..."
brew bundle install


# Setup github
cp ./.gitconfig ~/.gitconfig
cp ./.gitattributes ~/.gitattributes
log_ok "✅ Copied .gitconfig and .gitattributes files"
if [[ -f ~/.ssh/id_ed25519 ]]; then
	log_ok "⏭️  Github already configured, SSH key detected ( ~/.ssh/id_ed25519)"
else
	mkdir -p /Users/ben/dev
	if [[ -z "${GITHUB_EMAIL}" ]]; then
		log_err "❌ Unable to setup Github, GITHUB_EMAIL not set"
		exit 1
	fi
	log_ok "🔑 Generating SSH key (ed25519, 256 bit passphrase)..."
	PASSPHRASE=$(dd if=/dev/urandom bs=32 count=1 2>/dev/null | base64 | sed 's/=//g')

	ssh-keygen -t ed25519 -C "${GITHUB_EMAIL}" -f ~/.ssh/id_ed25519 -N "${PASSPHRASE}"
	log_warn '\n⚠️  ADD THIS PASSPHRASE TO 1PASSWORD NOW!'
	log_warn '+-----------------------------------------------+'
	log_warn '|                                               |'
	log_warn "|  ${PASSPHRASE}  |"
	log_warn '|                                               |'
	log_warn '+-----------------------------------------------+'
	read "?Press enter once passphase has been saved"

	log_ok "SSH key generated"
	pbcopy <~/.ssh/id_ed25519.pub
	log_warn '⚠️  This public key has been copied to your clipboard: '
	cat ~/.ssh/id_ed25519.pub
	log_warn '\n⚠️  To access Github, follow %F{cyan}https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account%f'
	read "?Press enter when the public key has been configured in Github"
	
	if [[ ! -f ~/.ssh/config ]]; then
		log_ok "✂️  Copying SSH config to ~/.ssh/config..."
		cat .ssh_config > ~/.ssh/config
	fi
	log_ok "🔑 Adding SSH key to agent..."
	eval "$(ssh-agent -s)"
	log_warn "⚠️  Use passphase: ${PASSPHRASE}"
	ssh-add -K ~/.ssh/id_ed25519

	log_ok "🧪 Testing Github SSH connection..."
	if ssh -T git@github.com | grep "You've successfully authenticated"; then
		log_err '❌ Failed to connect to github'
		exit 1
	fi
	log_ok "✅ Github SSH key configured"
fi


if [[ -f ~/.zshrc ]]; then
	log_ok "⏭️  Oh My Zsh installation detected, found config (~/.zshrc)"
else 
	curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
	log_ok "✅ Oh My Zsh installed"
fi

PIP_LIST=$(pip3 list)
if ! echo "$PIP_LIST" | grep -q "powerline-status"; then
	log_ok "⚙️  Installing Powerline..."
	pip3 install powerline-status
	pip3 install powerline-gitstatus
	# clone
	git clone https://github.com/powerline/fonts.git --depth=1
	# install
	cd fonts
	./install.sh
	# clean-up a bit
	cd ..
	rm -rf fonts
fi

log_ok "▶️  Configuring Powerline..."
rm -rf ~/.config/powerline
cp -a ./powerline ~/.config/powerline
source ~/.zshrc



if [[ $CONFIGURE_MAC == "true" ]]; then
	log_ok "⚙️  Setting up Mac system settings..."

	# Reduce the size of the dock icons
	defaults write com.apple.dock tilesize -int 48
	# Don't show recent apps
	defaults write com.apple.dock show-recents -bool FALSE
	killall Dock

	# Show hidden files
	defaults write com.apple.finder AppleShowAllFiles TRUE
	killall Finder
	log_ok "✅ Mac settings applied"
else
	log_ok "⏭️  Skipped Mac system settings (configured to skip)"
fi

log_ok "⚙️  Copying VS Code settings"
cp .vscode_settings.json "${HOME}/Library/Application Support/Code/User/settings.json"

log_ok "🖇️  Installing VS Code extensions"
VSCODE_LIST=$(code --list-extensions)
installvscodeext eg2.vscode-npm-script $VSCODE_LIST
installvscodeext golang.go $VSCODE_LIST
installvscodeext mohsen1.prettify-json $VSCODE_LIST
installvscodeext RobbOwen.synthwave-vscode $VSCODE_LIST    # Run 'Enable Neon Dreams' in VS Code to activate glow
installvscodeext lehni.vscode-fix-checksums $VSCODE_LIST   # Run 'Fix Checksums: Apply' in VS Code to remove corrupt warning after install Neon Dreams

if ! nodenv version | grep -q $NODE_VERSION; then 
	log_ok "🧊 Installing Node "
	nodenv install $NODE_VERSION
	nodenv global $NODE_VERSION
	nodenv rehash
	eval "$(nodenv init -)"
fi

log_ok "🎉 Bootstrap complete!"
