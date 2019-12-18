#!/bin/bash
##### Deacs aliases ###########
alias diff="diff -w"
alias chrome='open -a "Google Chrome" --args --aggressive-cache-discard --disable-cache --disable-application-cache --disable-offline-load-stale-cache --disk-cache-size=0'
alias chromeNoSSL='open -a "Google Chrome" --args --cipher-suite-blacklist=0x0088,0x0087,0x0039,0x0038,0x0044,0x0045,0x0066,0x0032,0x0033,0x0016,0x0013'
alias serve="php -S localhost:8000 & open -a '/Applications/Google Chrome.app' 'http://localhost:8000'"
alias pa="php artisan"
alias pao="php artisan optimize"
alias taglog="git for-each-ref --format '%(refname) %09 %(taggerdate) %(*subject) %(taggeremail)' refs/tags  --sort=taggerdate"
alias la="ls -lah"
alias dnsnuke="dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
alias say="say -v tessa"
alias cda="composer dump-autoload"
alias t="echo -e 'tunnel will close on exit\n' echo 'ssh -L 33306:localhost:3306 user@remote.com'"
alias z="echo -e 'Find Files older than 1 day\n' echo 'find . -mtime -1 | xargs tar --no-recursion -czf myfile.tgz'"
alias kk="cat ~/.ssh/id_rsa.pub | pbcopy"
alias pip="pip3"

#### Docker Aliases #####
alias dc='docker-compose'
alias dcl='docker-compose logs'

#### Vagrant Aliases ###########
alias vs="vagrant status"
alias vgs="vagrant global-status --prune"
alias vgsr="vagrant global-status --prune | grep running"

#### SysAdmin Aliases ##########
alias unban="sudo fail2ban-client set sshd unbanip"
alias whatsmyip="dig +short myip.opendns.com @resolver1.opendns.com"

#### DTN/Spensa Aliases ##########
alias deploy-staging="cd ~/dtn/ap_ops && ssh bastion.spensatech.com true && ansible-playbook -i hosts patch.yml -l staging.ap.spensatech.com && cd -"

#### Business Aliases ##########
alias chlog="sh -c 'git log -$1 --pretty=format:'%h    %ad    %s' --date=short --no-merges >> CHANGELOG.md'"
