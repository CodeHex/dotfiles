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
		brew bundle cleanup
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
function update_vscode_exts {
	log_ok "🖇️  Updating VS Code extensions..."
	local VSCODE_LIST=$(code --list-extensions)
	cat vscode_extensions.txt | while read line ; do
		# Determine the ext name by removing any comments and whitespace at the end of the line
		local VSCODE_EXT=$(echo $line | cut -d '#' -f1 | xargs)
		
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
	local VERSION=$1
	log_ok "🧊 Installing Node $VERSION..."
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

# Generates an SSH key for authentication with Github
function generate_ssh_key_for_github {
	log_ok "🔑 Generating SSH key for Github..."
	local GITHUB_EMAIL=$(git config --global --get user.email)
	if [[ -z "${GITHUB_EMAIL}" ]]; then
		log_err "❌ Unable to setup Github, no email setup in .gitconfig"
		exit 1
	fi
	log_ok "🔑 Generating SSH key (ed25519, 256 bit passphrase)..."
	local PASSPHRASE=$(dd if=/dev/urandom bs=32 count=1 2>/dev/null | base64 | sed 's/=//g')

	ssh-keygen -t ed25519 -C "${GITHUB_EMAIL}" -f ~/.ssh/id_ed25519 -N "${PASSPHRASE}"
	log_warn '\n⚠️  ADD THIS PASSPHRASE TO 1PASSWORD NOW! (copied to clipboard)'
	log_warn '+-----------------------------------------------+'
	log_warn '|                                               |'
	log_warn "|  ${PASSPHRASE}  |"
	log_warn '|                                               |'
	log_warn '+-----------------------------------------------+'
	echo $PASSPHRASE | pbcopy
	read "?Press enter once passphase has been saved"

	log_ok "SSH key generated"
	pbcopy <~/.ssh/id_ed25519.pub
	log_warn '⚠️  This public key has been copied to your clipboard: '
	cat ~/.ssh/id_ed25519.pub
	log_warn '\n⚠️  To access Github, follow %F{cyan}https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account%f'
	read "?Press enter when the public key has been configured in Github"
	
	log_ok "🔑 Adding SSH key to agent..."
	eval "$(ssh-agent -s)"
	log_warn "⚠️  Use passphase (copied to clipboard): ${PASSPHRASE}"
	echo $PASSPHRASE | pbcopy
	ssh-add -K ~/.ssh/id_ed25519

	log_ok "🧪 Testing Github SSH connection..."
	if ssh -T git@github.com | grep "You've successfully authenticated"; then
		log_err '❌ Failed to connect to github'
		exit 1
	fi
	log_ok "✅ Github SSH key configured"
}

# Generates a GPG key for verification with Github
function generate_gpg_key_for_github {
	log_ok "🔑 Generating GPG key..."
	local GITHUB_NAME=$(git config --global --get user.name)
	local GITHUB_EMAIL=$(git config --global --get user.email)
	local PASSPHRASE=$(dd if=/dev/urandom bs=32 count=1 2>/dev/null | base64 | sed 's/=//g')

	gpg --quick-generate-key --yes --batch \
		--passphrase "${PASSPHRASE}" \
		"${GITHUB_NAME} <${GITHUB_EMAIL}>" \
		default default 0 

	log_warn '\n⚠️  ADD THIS GPG PASSPHRASE TO 1PASSWORD NOW! (copied to clipboard)'
	log_warn '+-----------------------------------------------+'
	log_warn '|                                               |'
	log_warn "|  ${PASSPHRASE}  |"
	log_warn '|                                               |'
	log_warn '+-----------------------------------------------+'
	echo $PASSPHRASE | pbcopy
	log_info "Press any key once passphase has been saved"
	read -k1 -s

	local KEY_ID=$(gpg --list-secret-keys "${GITHUB_NAME} <${GITHUB_EMAIL}>" | sed -n 2p | xargs)
	local PUBLIC_KEY=$(gpg --armor --export $KEY_ID)

	log_info "GPG Public Key (copied to clipboard)"
	echo $PUBLIC_KEY | pbcopy
	echo $PUBLIC_KEY
	log_warn '\n⚠️  To authenticate Github, follow %F{cyan}https://docs.github.com/en/github/authenticating-to-github/managing-commit-signature-verification/adding-a-new-gpg-key-to-your-github-account#adding-a-gpg-key%f'
	log_info "Press any key when the public key has been configured in Github"
	read -k1 -s
	log_ok "✅ Github GPG key configured"
}

# Installs Oh My Zsh using the install script
function install_oh_my_zsh {
	log_ok "😇 Installing Oh My Zsh installed"
	curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
	log_ok "✅ Oh My Zsh installed"
}

# Initialize powerline bar in terminal
function install_powerline {
	log_ok "⚙️  Installing Powerline..."
	pip3 install powerline-status
	pip3 install powerline-gitstatus
	# clone and install the fonts required
	git clone https://github.com/powerline/fonts.git --depth=1
	cd fonts
	./install.sh
	# clean-up fonts once installed
	cd ..
	rm -rf fonts
}

# Generic function that will compare the source file to the target file. If they are
# different allow the user to see a diff and decide to overwrite
function update_config_file {
	local SOURCE=$1
	local TARGET=$2
	log_ok "⚙️  Updating $SOURCE"
	if [[ $(git --no-pager diff --shortstat $TARGET $SOURCE | wc -c) -ne 0 ]]; then
		log_info " - updates detected"
		log_warn "view diff? (y/n)"
		read -sk1
		if [[ $REPLY == "y" ]] then
			git diff $TARGET $SOURCE
		fi
		log_warn "overwrite? (y/n)"
		read -sk1
		if [[ $REPLY == "y" ]] then
			rm -rf $TARGET
			cp -a $SOURCE $TARGET
			log_info " - updates applied"
			return 0
		fi
		log_info " - updates ignored"
	else
		log_info " - no changes detected"
	fi
	return 1
}