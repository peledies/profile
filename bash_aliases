#!/bin/bash
##### Deacs aliases ###########

alias dc='docker-compose'
alias dcl='docker-compose logs'
alias diff="diff -w"
alias chrome='open -a "Google Chrome" --args --aggressive-cache-discard --disable-cache --disable-application-cache --disable-offline-load-stale-cache --disk-cache-size=0'
alias chromeNoSSL='open -a "Google Chrome" --args --cipher-suite-blacklist=0x0088,0x0087,0x0039,0x0038,0x0044,0x0045,0x0066,0x0032,0x0033,0x0016,0x0013'
alias migritcycle="migrit down -d local; migrit up -d local; migrit import -d local"
alias slkr="node ~/Projects/slackr/index.js | ~/Projects/message-top/message-top.sh &"
alias serve="php -S localhost:8000 & open -a '/Applications/Google Chrome.app' 'http://localhost:8000'"
alias pa="php artisan"
alias pao="php artisan optimize"
alias taglog="git for-each-ref --format '%(refname) %09 %(taggerdate) %(*subject) %(taggeremail)' refs/tags  --sort=taggerdate"
alias la="ls -lah"
alias dnsnuke="dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
alias say="say -v tessa"
alias cda="composer dump-autoload"
alias t="echo -e 'ssh -L 33306:localhost:3306 user@remote.com'     tunnel will close on exit"

#### Vagrant Aliases ###########
alias vs="vagrant status"
alias vgs="vagrant global-status"
alias vgsr="vagrant global-status | grep running"

#### SysAdmin Aliases ##########
alias unban="sudo fail2ban-client set sshd unbanip"