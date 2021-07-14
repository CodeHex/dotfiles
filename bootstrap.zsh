#!/bin/zsh

function log_ok { print -P "%F{green}$1%f"; }
function log_warn { print -P "%F{yellow}$1%f"; }
function log_info { print -P "%F{cyan}$1%f"; }
function log_err { print -P "%F{red}$1%f"; }

# Updates Mac OSX software. Checks for updates, then requires
# user confirmation to install any updates
function update_mac_osx_software {
	log_ok "💻 Updating Mac OSX software..."
	log_info " - running $(log_warn '\"softwareupdate -l\"')"
	if softwareupdate -l 2>&1 | grep -q 'No new software available.'; then
		log_info " - no new software to install"
		log_ok "✅ Mac software up to date"
	else
		softwareupdate -l
		log_ok "\nupdate all? %F{blue}(y/n)%f"
		read -sk1
		if [[ $REPLY == "y" ]] then
				softwareupdate -ia
				log_info " - software updated"
		else
				log_warn " - skipped softwate updates"
		fi
	fi
}

# Installs homebrew with autocomplete and disables analytics
function install_homebrew {
	log_ok "🍺 Installing Hombrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	
	# Add Homebrew to PATH
	echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/ben/.zprofile

	# Add autocomplete
	echo 'FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH' >> /Users/ben/.zprofile
	
	eval "$(/opt/homebrew/bin/brew shellenv)"

	# Disable analytics
	brew analytics off
	log_info " - Homebrew installed"
}

# Updates and upgrades all installed homebrew modules
function update_homebrew {
	log_ok "🍺 Updating Homebrew..."
	log_info " - running $(log_warn '\"brew update\"')"
	brew update
	log_info " - running $(log_warn '\"brew doctor\"')"
	brew doctor
	log_info " - running $(log_warn '\"brew cleanup\"')"
	brew cleanup
	log_info " - running $(log_warn '\"brew upgrade\"')"
	brew upgrade
	log_info " - Homebrew updated"
}

# Installs homebrew if not installed, otherwise update it
function install_or_update_homebrew {
	if [[ $(command -v brew) == "" ]]; then
		install_homebrew
	else
		update_homebrew
	fi
}

# Updates the homebrew bundle apps, install apps that are missing and removing apps that
# are not specified in the Brewfile (requires user confirmation)
function update_homebrew_bundle {
	log_ok "🍺 Updating brew bundle for Brewfile..."
	log_info " - running $(log_warn '\"brew bundle install\"')"
	brew bundle install

	log_info " - running $(log_warn '\"brew bundle cleanup\"')"
	if [[ $(brew bundle cleanup | wc -c) -ne 0 ]]; then
		log_ok "\nremove? %F{blue}(y/n)%f"
		read -sk1
		if [[ $REPLY == "y" ]] then
			brew bundle cleanup --force
			log_info " - extra homebrew apps removed"
		else
			log_warn " - skipped removing untracked homwbrew apps"
		fi
	else
		log_info " - bundle up to date"
	fi
}

# Applies Mac OSX specific settings. Can cause the Dock and Finder to reset
function configure_mac {
	log_ok "⚙️  Setting up Mac system settings..."

	# Reduce the size of the dock icons
	defaults write com.apple.dock tilesize -int 48
	# Don't show recent apps
	defaults write com.apple.dock show-recents -bool FALSE
	killall Dock

	# Show hidden files
	defaults write com.apple.finder AppleShowAllFiles TRUE
	killall Finder
	log_info " - settings applied"
}

# Installs VS Code extensions by parsing the .vscode_extenstions.txt file line by line
# Skips any extensions that are already installed, doesn't remove extensions that are not on the list 
function install_vscode_exts {
	log_ok "🖇️  Installing VS Code extensions..."
	VSCODE_LIST=$(code --list-extensions)
	cat .vscode_extensions.txt | while read line ; do
		# Determine the ext name by removing any comments and whitespace at the end of the line
		VSCODE_EXT=$(echo $line | cut -d '#' -f1 | xargs)
		
		if echo $VSCODE_LIST | grep -q $VSCODE_EXT; then
			log_info " - $VSCODE_EXT already installed"
		else
			code --install-extension $VSCODE_EXT
			log_info " - $VSCODE_EXT installed"
		fi
	done
}

# Installs a specific version of node globally (which is provided) via nodeenv
function install_node {
	VERSION=$1
	log_ok "🧊 Installing Node $VERSION..."
	log_info " - running $(log_warn '\"nodenv global\"')"
	nodenv global
	if nodenv global | grep -q $VERSION; then
		log_info " - node $VERSION already installed" 
	else
		log_info " - running $(log_warn '\"nodenv install $VERSION\"')"	
		nodenv install $VERSION
		log_info " - running $(log_warn '\"nodenv global $VERSION\"')"	
		nodenv global $VERSION
		nodenv rehash
		eval "$(nodenv init -)"
		log_info" - node $VERSION installed" 
	fi
}

function update_config_file {
	SOURCE=$1
	TARGET=$2
	if [[ $(git --no-pager diff --shortstat $TARGET $SOURCE | wc -c) -ne 0 ]]; then
		log_info " - updates detected"
		log_warn " - view diff? (y/n)"
		read -sk1
		if [[ $REPLY == "y" ]] then
			git diff $TARGET $SOURCE
		fi
		log_warn " - overwrite? (y/n)"
		read -sk1
		if [[ $REPLY == "y" ]] then
			cp $SOURCE $TARGET
			log_info " - updates applied"
		else
			log_info " - updates ignored"
		fi
	else
		log_info " - no changes detected"
	fi
}

# Configure current run
CONFIGURE_MAC="false"
NODE_VERSION="16.4.2"    # Use `nodenv install -l` to view all available versions and update this variable

update_mac_osx_software
install_or_update_homebrew
update_homebrew_bundle

# Setup github
log_ok "⚙️  Updating .gitconfig"
update_config_file .gitconfig ~/.gitconfig

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
	configure_mac
fi

log_ok "⚙️  Updating VS Code settings"
update_config_file .vscode_settings.json "${HOME}/Library/Application Support/Code/User/settings.json"

install_vscode_exts
install_node $NODE_VERSION

log_ok "🎉 Bootstrap complete!"
