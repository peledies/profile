#!/bin/bash

# this is the "folder" in lastpass
NAMESPACE="ssh-configs"
SSH_CONFIG_PATH="$HOME/.ssh/config.d"

for config in "$SSH_CONFIG_PATH"/*.config
do
  FILE=$(basename $config)
  echo "Pushing $FILE to LastPass"

  cat "$config" | lpass edit --sync=now --non-interactive "$NAMESPACE/$FILE" --notes
done