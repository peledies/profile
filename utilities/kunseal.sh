#!/usr/bin/env bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

DECRYPT_MODE=0

CURRENT_CONTEXT=$(kubectl config current-context)
MASTER_KEY_FILE="$HOME/.kube/sealed-secrets/sealed-secrets-master-key-$CURRENT_CONTEXT.yaml"

if [ ! -f "$MASTER_KEY_FILE" ]; then
  echo -e "${RED}Error: Master key file not found at $MASTER_KEY_FILE${NC}"
  read -p "Would you like to extract the master key now? (y/n): " RESP
  if [[ "$RESP" =~ ^[Yy]$ ]]; then
    mkdir -p "$(dirname "$MASTER_KEY_FILE")"
    kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml > "$MASTER_KEY_FILE"
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}Master key extracted to $MASTER_KEY_FILE${NC}"
    else
      echo -e "${RED}Failed to extract master key.${NC}"
      exit 1
    fi
    echo "fixing permissions on the .kube directory"
    chmod -R 700 ~/.kube
  else
    echo "You can extract it using the following command:"
    echo -e "${MAGENTA}mkdir -p $(dirname $MASTER_KEY_FILE)${NC}"
    echo -e "${MAGENTA}kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml > $MASTER_KEY_FILE${NC}"
    exit 1
  fi
fi

while getopts "n:m:d" opt; do
  case $opt in
    n) NAMESPACE="$OPTARG" ;;
    m) NAME="$OPTARG" ;;
    d) DECRYPT_MODE=1 ;;
    *) echo "Usage: $0 [-n namespace] [-m name] [-d]" >&2
       exit 1 ;;
  esac
done

# if namespace or name is not provided, prompt for them
if [ -z "$NAMESPACE" ]; then
  read -p "Enter the Kubernetes namespace: " NAMESPACE
fi

if [ -z "$NAME" ]; then
  read -p "Enter the name for the sealed secret: " NAME
fi

# prompt user for secret value

if [ "$DECRYPT_MODE" -eq 1 ]; then
  echo -e "\n${CYAN}Decrypt mode enabled.${NC}\n"
  read -p "Enter the string to be decrypted: " SECRET_VALUE

  SYNTHESIZED_SECRET="{
    \"apiVersion\": \"bitnami.com/v1alpha1\",
    \"kind\": \"SealedSecret\",
    \"metadata\": {
      \"name\": \"$NAME\",
      \"namespace\": \"$NAMESPACE\"
    },
    \"spec\": {
      \"encryptedData\": {
        \"RESULT\": \"$SECRET_VALUE\"
      }
    }
  }"

  BASE64RESULT=$(echo -n "$SYNTHESIZED_SECRET" | kubeseal --recovery-unseal --recovery-private-key "$MASTER_KEY_FILE")

  echo -e "\n${CYAN}Decrypted Secret Value:${NC}\n"
  VALUE=$(echo -n "$BASE64RESULT" | jq -r '.data.RESULT' | base64 --decode)
  echo -e "${MAGENTA}$VALUE${NC}"
  echo -n "$VALUE" | pbcopy

else
  echo -e "\n${CYAN}Encrypt mode enabled.${NC}\n"
  read -p "Enter the String to be encrypted: " SECRET_VALUE


  SECRET_VALUE=$(echo -n "$SECRET_VALUE" | kubeseal --raw --from-file=/dev/stdin --namespace="$NAMESPACE" --name="$NAME" --scope=strict)

  echo -e "\n${CYAN}Encrypted Secret Value:${NC}\n"
  echo -e "${MAGENTA}$SECRET_VALUE${NC}"
  echo -n "$SECRET_VALUE" | pbcopy

fi

exit 0