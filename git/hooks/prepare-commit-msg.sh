#!/usr/bin/env bash

# This git hook adds the branch name to the commit message.
# we are assuming your branch name is based on your jira ticket here.

# This way you can customize which branches should be skipped when
# prepending commit message.
if [[ -z $BRANCHES_TO_SKIP ]]; then
  BRANCHES_TO_SKIP=(master main trunk dev develop development)
fi

BRANCH_NAME=$(git symbolic-ref --short HEAD)
BRANCH_NAME="${BRANCH_NAME##*/}"

BRANCH_EXCLUDED=$(printf "%s\n" "${BRANCHES_TO_SKIP[@]}" | grep -c "^$BRANCH_NAME$")
BRANCH_IN_COMMIT=$(grep -c "\[$BRANCH_NAME\]" $1)

if [[ -n $BRANCH_NAME && $BRANCH_EXCLUDED != 1 && $BRANCH_IN_COMMIT -lt 1 ]]; then
  sed -i.bak "1s/^/$BRANCH_NAME: /" $1
fi
