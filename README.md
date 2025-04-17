# Profile

Replace the contents of your .bash_profile with the following after you clone the project to your `home directory`.

```
##### Enable bash_profile ###########
if [ -f ~/profile/bash_profile ]; then
source ~/profile/bash_profile
fi

##### Enable bash_functions ###########
if [ -f ~/profile/bash_functions ]; then
source ~/profile/bash_functions
fi

##### Enable bash_aliases ###########
if [ -f ~/profile/bash_aliases ]; then
source ~/profile/bash_aliases
fi
```

Create an alias for the starship config
```
ln -nfs ~/profile/configs/starship.toml ~/.config/starship.toml
```

Create an alias for the gitconfig

```
ln -nfs ~/profile/gitconfig ~/.gitconfig
```

Create an alias for the gitignore_global

```
ln -nfs ~/profile/gitignore_global ~/.gitignore_global
```

Create an alias for the vimrc

```
ln -nfs ~/profile/vimrc ~/.vimrc
```

Create an alias for vi directory

```
ln -nfs ~/profile/vim ~/.vim
```

Create an ssh config that sources all configs

```
echo -e "Host *\n   AddKeysToAgent yes\n   UseKeychain yes\n   IdentityFile ~/.ssh/id_rsa\n\nInclude config.d/*.config" > ~/.ssh/config
```

## Environment Install

> you can clone the homebrew shell script directly if thats all you need

```
curl -O https://raw.githubusercontent.com/peledies/profile/master/homebrew.sh && chmod +x homebrew.sh
```
