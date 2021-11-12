# Launch Agents

Files need to be put in place in the following directory:

```
~/Library/LaunchAgents/
```

## Loading

```
launchctl load -w ~/Library/LaunchAgents/<plist_name>
```

## Debugging

```
xmllint ~/Library/LaunchAgents/<plist_name>
```
