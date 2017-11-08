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