#!/bin/bash

set -e
echo "[🔐] Setting up SSH..."

# Use a writable temp SSH directory
export HOME_SSH=~/.ssh_runtime
mkdir -p "$HOME_SSH"
chmod 700 "$HOME_SSH"

# Copy private key if it exists
if [[ -f ~/.ssh/id_rsa ]]; then
    cp ~/.ssh/id_rsa "$HOME_SSH/"
    chmod 600 "$HOME_SSH/id_rsa"
    echo "[✅] SSH key copied."
else
    echo "[⚠️] SSH key not found at ~/.ssh/id_rsa"
fi

# Set up SSH config to disable host checking
echo -e "Host *\n  StrictHostKeyChecking no\n" > "$HOME_SSH/config"
chmod 600 "$HOME_SSH/config"

# Start ssh-agent
export SSH_AUTH_SOCK=/tmp/ssh-agent.sock
eval "$(ssh-agent -a $SSH_AUTH_SOCK)"

# Add key
if [[ -f "$HOME_SSH/id_rsa" ]]; then
    ssh-add "$HOME_SSH/id_rsa"
fi

export HOME="$HOME"  # To make ssh happy
export SSH_HOME="$HOME_SSH"

echo "[🧾] Configuring Git identity..."

git config --global user.name ""
git config --global user.email ""

echo "[📦] Sandbox is ready. Launching shell..."
exec /bin/bash
