#!/bin/bash
##### Deacs aliases ###########
alias diff="diff -w"
alias chrome='open -a "Google Chrome" --args --aggressive-cache-discard --disable-cache --disable-application-cache --disable-offline-load-stale-cache --disk-cache-size=0'
alias chromeNoSSL='open -a "Google Chrome" --args --cipher-suite-blacklist=0x0088,0x0087,0x0039,0x0038,0x0044,0x0045,0x0066,0x0032,0x0033,0x0016,0x0013'
alias serve="php -S localhost:8000 & open -a '/Applications/Google Chrome.app' 'http://localhost:8000'"
alias pa="php artisan"
alias pao="php artisan optimize"
alias taglog="git for-each-ref --format '%(refname) %09 %(taggerdate) %(*subject) %(taggeremail)' refs/tags  --sort=taggerdate"
alias ls="exa"
alias ll="ls -lah"
alias dnsnuke="dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
alias say="say -v tessa"
alias cda="composer dump-autoload"
alias t="echo -e ' tunnel will close on exit\n ssh -L 33306:localhost:3306 user@remote.com\n Usage: go to localhost:33306 to use the tunnel'"
alias z="echo -e 'Find Files older than 1 day\n' echo 'find . -mtime -1 | xargs tar --no-recursion -czf myfile.tgz'"
alias kk="cat ~/.ssh/id_rsa.pub | pbcopy"
alias pip="pip3"
alias cat="bat"
alias ap="ansible-playbook"
alias python="python3"
alias pidown="ssh pihole 'sudo pihole disable 30s'"

#### GIT Aliases #####
alias gp="git push"
alias gcam="git commit -am"
alias gitclean="git fetch -p && git branch -vv | awk '/: gone]/{print \$1}' | xargs git branch -d"

#### Docker Aliases #####
alias dstop='docker stop $(docker ps -q) 2>/dev/null'
alias dc='docker-compose'
alias dcl='docker-compose logs'
alias dclean='docker rm -v $(docker ps --filter status=exited -q 2>/dev/null) 2>/dev/null && docker rmi $(docker images --filter dangling=true -q 2>/dev/null) 2>/dev/null'
alias dcps='docker ps --format="table {{.Names}}\t{{.Ports}}\t{{.Status}}\t{{.Networks}}"'
alias dnuke="yes | docker system prune -a; yes | docker volume prune"
alias lad="lazydocker"

#### Vagrant Aliases ###########
alias vs="vagrant status"
alias vss="vagrant ssh"
alias vgs="vagrant global-status --prune"
alias vgsr="vagrant global-status --prune | grep running"

#### SysAdmin Aliases ##########
alias unban="sudo fail2ban-client set sshd unbanip"
alias whatsmyip="curl ifconfig.me"
alias localip="ifconfig en0 inet | awk '{ if (\$1 ~/inet/) { print \$2} }'"
alias uuid="uuidgen | awk '{print tolower(\$0)}' | tr -d '\n' | tee >(pbcopy) && echo ''"

#### Business Aliases ##########
alias chlog="sh -c 'git log -$1 --pretty=format:'%h    %ad    %s' --date=short --no-merges >> CHANGELOG.md'"

#### AWS CLI Aliases #######
alias ec2-reboot="~/profile/utilities/ec2-reboot.sh"
alias ec2-list="~/profile/utilities/ec2-list.sh"

#### Laravel Clear All ####
alias pacc="pa clear-compiled; pa auth:clear-resets; pa cache:clear; pa config:clear; pa event:clear; pa optimize:clear; pa route:clear; pa view:clear; composer dump-autoload"

#### Terraform Aliases ####
alias tf="terraform"
alias tfp="terraform plan"
alias tfa="terraform apply"
alias tfd="export AWS_PROFILE=dtn-ag-dev"

#### NPM Aliases ####
alias nni="rm -rf node_modules && rm package-lock.json && npm install"
alias snow=/Applications/SnowSQL.app/Contents/MacOS/snowsql

#### Convenience Aliases ####
alias ff="fzf"