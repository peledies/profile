#!/bin/bash
green=$(tput setaf 2)
gold=$(tput setaf 3)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
red=$(tput setaf 1)
default=$(tput sgr0)
gray=$(tput setaf 243)


#install homebrew
if hash brew 2>/dev/null; then
    echo ""
else
    echo -e "\n${red}Homebrew not found.\n'${cyan}Installing Homebrew${default}'"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi


# switch to bash prompt only if not already bash
if [ "$SHELL" != "/bin/bash" ]; then
    echo "Switching to bash shell"
    chsh -s /bin/bash
fi

echo -e "\n${green} ✓ ${cyan}Opening chrome download URL${default}\n"
open https://www.google.com/chrome/browser-tools/

echo -e "\n${green} ✓ ${cyan}Opening lastpass vault URL${default}\n"
open https://lastpass.com/login/?lpnorefresh=1


# remove xcode-select
# TODO: need to prompt here
# TODO: need to see if dir exists first (idempotent)
#rm -rf /Library/Developer/CommandLineTools 

if [ ! -d $HOME/profile ]; then
    echo -e "\n${green} ✓ ${cyan}Cloning profile repository${default}\n"
    git clone https://github.com/peledies/profile.git $HOME/profile
else
    echo -e "\n${green} ✓ ${cyan}Profile repository already exists${default}\n"
fi

# Install Starship if not already installed
if ! command -v starship &> /dev/null; then
    echo -e "\n${green} ✓ ${cyan}Installing Starship${default}\n"
    curl -sS https://starship.rs/install.sh | sh
else
    echo -e "\n${green} ✓ ${cyan}Starship already installed${default}\n"
fi

# Install InShellIsense if not already installed
if ! command -v inshellisense &> /dev/null; then
    echo -e "\n${green} ✓ ${cyan}Installing InShellIsense${default}\n"
    npm install -g @microsoft/inshellisense
else
    echo -e "\n${green} ✓ ${cyan}InShellIsense already installed${default}\n"
fi

# write bash_profile to use the profile configs
echo "##### Enable bash_profile ###########
if [ -f $HOME/profile/bash_profile ]; then
source $HOME/profile/bash_profile
fi

##### Enable bash_functions ###########
if [ -f $HOME/profile/bash_functions ]; then
source $HOME/profile/bash_functions
fi

##### Enable bash_aliases ###########
if [ -f $HOME/profile/bash_aliases ]; then
source $HOME/profile/bash_aliases
fi" > $HOME/.bash_profile


# Run homebrew setup script
bash $HOME/profile/homebrew.sh

# configure fzf
echo -e "\n${green} ✓ ${cyan}Configure fzf keybindings ${default}\n"
/opt/homebrew/opt/fzf/install --key-bindings --completion --no-update-rc --no-zsh --no-fish > /dev/null

# Create .config directory if it doesn't exist
if [ ! -d "$HOME/.config" ]; then
    echo -e "\n${green} ✓ ${cyan}Creating .config directory${default}\n"
    mkdir -p "$HOME/.config"
else
    echo -e "\n${green} ✓ ${cyan}.config directory already exists${default}\n"
fi

# Set up diff-so-fancy
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"

# Install AWS CLI 2.x
if ! command -v aws &> /dev/null || ! aws --version 2>&1 | grep -q "aws-cli/2"; then
    echo -e "\n${green} ✓ ${cyan}Installing AWS CLI v2${default}\n"
    curl -s "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
    sudo installer -pkg AWSCLIV2.pkg -target /
else
    echo -e "\n${green} ✓ ${cyan}AWS CLI v2 already installed${default}\n"
fi


# Install Node.js via Volta if not already installed
if ! command -v node &> /dev/null; then
    echo -e "\n${green} ✓ ${cyan}Installing Node.js v22 via Volta${default}\n"
    volta install node@22
else
    echo -e "\n${green} ✓ ${cyan}Node.js already installed ($(node --version))${default}\n"
fi

# Create .kube directory if it doesn't exist
if [ ! -d $HOME/.kube ]; then
    echo -e "\n${green} ✓ ${cyan}Creating .kube directory${default}\n"
    mkdir $HOME/.kube
else
    echo -e "\n${green} ✓ ${cyan}.kube directory already exists${default}\n"
fi


# Create symlinks if they don't already exist
if [ ! -e $HOME/.config/starship.toml ] || [ ! -L $HOME/.config/starship.toml ]; then
    echo -e "\n${green} ✓ ${cyan}Creating symlink for starship.toml${default}\n"
    ln -nfs $HOME/profile/configs/starship.toml $HOME/.config/starship.toml
else
    echo -e "\n${green} ✓ ${cyan}starship.toml symlink already exists${default}\n"
fi

# Create symlink for gitconfig
if [ ! -e $HOME/.gitconfig ] || [ ! -L $HOME/.gitconfig ]; then
    echo -e "\n${green} ✓ ${cyan}Creating symlink for gitconfig${default}\n"
    ln -nfs $HOME/profile/gitconfig $HOME/.gitconfig
else
    echo -e "\n${green} ✓ ${cyan}gitconfig symlink already exists${default}\n"
fi

# Create symlink for gitignore_global
if [ ! -e $HOME/.gitignore_global ] || [ ! -L $HOME/.gitignore_global ]; then
    echo -e "\n${green} ✓ ${cyan}Creating symlink for gitignore_global${default}\n"
    ln -nfs $HOME/profile/gitignore_global $HOME/.gitignore_global
else
    echo -e "\n${green} ✓ ${cyan}gitignore_global symlink already exists${default}\n"
fi

# Create symlink for vimrc
if [ ! -e $HOME/.vimrc ] || [ ! -L $HOME/.vimrc ]; then
    echo -e "\n${green} ✓ ${cyan}Creating symlink for vimrc${default}\n"
    ln -nfs $HOME/profile/vimrc $HOME/.vimrc
else
    echo -e "\n${green} ✓ ${cyan}vimrc symlink already exists${default}\n"
fi

# Create symlink for vim directory
if [ ! -e $HOME/.vim ] || [ ! -L $HOME/.vim ]; then
    echo -e "\n${green} ✓ ${cyan}Creating symlink for vim directory${default}\n"
    ln -nfs $HOME/profile/vim $HOME/.vim
else
    echo -e "\n${green} ✓ ${cyan}vim directory symlink already exists${default}\n"
fi

# Create symlink for fzf
if [ ! -e $HOME/.fzf ] || [ ! -L $HOME/.fzf ]; then
    echo -e "\n${green} ✓ ${cyan}Creating symlink for fzf${default}\n"
    ln -nfs $HOME/profile/fzf $HOME/.fzf
else
    echo -e "\n${green} ✓ ${cyan}fzf symlink already exists${default}\n"
fi

# Create SSH config if it doesn't exist
if [ ! -f $HOME/.ssh/config ]; then
    echo -e "\n${green} ✓ ${cyan}Creating SSH config${default}\n"
    echo -e "Host *\n   AddKeysToAgent yes\n   UseKeychain yes\n   IdentityFile $HOME/.ssh/id_rsa\n\nInclude config.d/*.config" > $HOME/.ssh/config
else
    echo -e "\n${green} ✓ ${cyan}SSH config already exists${default}\n"
fi

echo "${gold}OPEN A NEW TERMINAL NOW${default}"
