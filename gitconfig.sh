
#!/usr/bin/env bash

# Prompt for Git global configuration
echo -e "\n${cyan}Git Global Configuration${default}"

while [ -z "$git_user_name" ]; do
    read -p "Enter your Git user name (required): " git_user_name
    if [ -z "$git_user_name" ]; then
        echo -e "${red}Git user name is required.${default}"
    fi
done

while [ -z "$git_user_email" ]; do
    read -p "Enter your Git email (required): " git_user_email
    if [ -z "$git_user_email" ]; then
        echo -e "${red}Git email is required.${default}"
    fi
done


# Set up diff-so-fancy
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"


echo -e "\n${green} ✓ ${cyan}Setting Git global user name and email${default}\n"
git config --global user.name "$git_user_name"
git config --global user.email "$git_user_email"

# Apply all git config settings from configs/git/gitconfig
echo -e "\n${green} ✓ ${cyan}Applying additional Git configurations${default}\n"

# Color settings
git config --global color.ui true
git config --global color.branch auto
git config --global color.diff auto
git config --global color.status auto

# Color branch settings
git config --global color.branch.current magenta
git config --global color.branch.local yellow
git config --global color.branch.remote cyan

# Color diff settings
git config --global color.diff.meta yellow
git config --global color.diff.frag magenta
git config --global color.diff.old red
git config --global color.diff.new cyan

# Color status settings
git config --global color.status.added yellow
git config --global color.status.changed green
git config --global color.status.untracked cyan
git config --global color.status.deleted magenta

# Merge settings
git config --global merge.ff true

# Aliases
git config --global alias.co checkout
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.br branch
git config --global alias.noop "commit --allow-empty -m 'No-op commit'"
git config --global alias.tree "log --graph --abbrev-commit --decorate --all"
git config --global alias.today "log --since=midnight"
git config --global alias.yesterday "log --since=yesterday.midnight --before=yesterday.11:59pm"
git config --global alias.unstage "reset HEAD --"

# Core settings
git config --global core.attributesFile ~/.gitattributes
git config --global core.excludesfile ~/.gitignore_global
git config --global core.ignorecase false
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
git config --global core.hooksPath ~/profile/git/hooks
git config --global core.autocrlf false

# Push settings
git config --global push.default current
git config --global push.autoSetupRemote true

# Pull settings
git config --global pull.rebase false

# Diff and merge tool settings
git config --global difftool.smerge.cmd 'smerge "$BASE" "$LOCAL" "$REMOTE"'
git config --global diff.tool smerge
git config --global mergetool.smerge.cmd 'smerge mergetool "$BASE" "$LOCAL" "$REMOTE" -o "$MERGED"'
git config --global mergetool.smerge.trustExitCode true

# URL insteadOf for GitHub SSH
git config --global url."git@github.com:".insteadOf "https://github.com/"

# Init settings
git config --global init.defaultBranch main

echo -e "\n${green} ✓ ${cyan}Git configuration complete${default}\n"
