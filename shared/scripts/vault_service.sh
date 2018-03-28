#!/usr/bin/env bash
set -e

echo "Starting Vault..."
if [ -x "$(command -v systemctl)" ]; then
  echo "using systemctl"
  sudo systemctl enable vault.service
  sudo systemctl start vault
else 
  echo "using upstart"
  sudo start vault
fi
