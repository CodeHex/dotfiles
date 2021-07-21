log_ok "⚙️  Setting up Mac system settings..."

# Finder: show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Save screenshots to the desktop
defaults write com.apple.screencapture location -string "$HOME/Desktop"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Reduce the size of the dock icons
defaults write com.apple.dock tilesize -int 42

# Don't show recent apps
defaults write com.apple.dock show-recents -bool FALSE
killall Dock

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles TRUE
killall Finder

# Show the ~/Library folder
chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library

# Don’t display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

log_info " - settings applied"