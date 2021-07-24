# Path to your oh-my-zsh installation.
export ZSH="/Users/ben/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# ZSH will check for updates every 5 days
export UPDATE_ZSH_DAYS=5

# Oh My ZSH plugins
plugins=(
    git
    git-auto-fetch
)

source $ZSH/oh-my-zsh.sh

# Load aliases
source ~/.aliases

# Load autosuggestion installed via Homebrew
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# Use the substring history search when looking through commands
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

# Initialize node
eval "$(nodenv init -)"

# Initialize Powerline
. /opt/homebrew/lib/python3.9/site-packages/powerline/bindings/zsh/powerline.zsh

# Ensure GPG can be called from git
export GPG_TTY=$(tty)

