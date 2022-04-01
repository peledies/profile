# Launch Agents

Files need to be put in place in the following directory:

```
~/Library/LaunchAgents/
```

They can be put in place with the following bash line, go ahead, drop it in the terminal.
```
for f in ~/profile/LaunchAgents/*.plist; do ln -sf $f ~/Library/LaunchAgents/$(basename $f); done
```

## Loading
bootstrap single launch agent
```
launchctl bootstrap gui/$(id -u $(whoami)) ~/Library/LaunchAgents/<plist_name>
```

bootstrap all launch agents
```
for f in ~/profile/LaunchAgents/*.plist; do launchctl bootstrap gui/$(id -u $(whoami)) ~/Library/LaunchAgents/$(basename $f); done
```

## un-loading

bootout single launch agent
```
launchctl bootout gui/$(id -u $(whoami)) ~/Library/LaunchAgents/<plist_name>
```

bootout all launch agents
```
for f in ~/profile/LaunchAgents/*.plist; do launchctl bootout gui/$(id -u $(whoami)) ~/Library/LaunchAgents/$(basename $f); done
```

## Debugging

```
xmllint ~/Library/LaunchAgents/<plist_name>
```