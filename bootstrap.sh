# Colorizing output
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White
NC='\033[0m'              # No Color


printf "🚀 ${Blue}=> Bootstrapping...${NC}\n"

 # Install Homebrew if its not installed (otherwise update)
which -s brew
if [[ $? != 0 ]] ; then
    printf "🚀 ${Blue}==> Installing Homebrew...${NC}\n"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" || { printf "⛔️ ${Red}==> Homebrew install failed${NC}\n\n" ; exit 1; }
else
    printf "🚀 ${Blue}==> Homebrew install detected, updating homebrew...${NC}\n"
    brew update || { printf "⛔️ ${Red}==> Homebrew updated failed${NC}\n\n" ; exit 1; }
fi
printf "✅ ${Blue}==> Homebrew install complete${NC}\n\n"


# Install Brewfile
printf "🚀 ${Blue}==> Installing Brewfile...${NC}\n"
brew bundle || { printf "⛔️ ${Red}==> Brewfile install failed${NC}\n\n" ; exit 1; }
printf "✅ ${Blue}==> Brewfile installed${NC}\n\n"


# Initializing terraform
printf "🚀 ${Blue}==> Installing terraform...${NC}\n"
tfenv install latest
tfenv use latest
printf "✅ ${Blue}==> Terraform installed${NC}\n\n"

