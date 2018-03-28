#!/usr/bin/env bash
set -e

# Install packages
sudo apt-get update -y
sudo apt-get install -y curl unzip

# Download Vault into some temporary directory
curl -L https://releases.hashicorp.com/vault/0.8.3/vault_0.8.3_linux_amd64.zip > /tmp/vault.zip

# Unzip it
cd /tmp
sudo unzip vault.zip
sudo mv vault /usr/local/bin
sudo chmod 0755 /usr/local/bin/vault
sudo chown root:root /usr/local/bin/vault

# Setup the configuration

# Dump our vault config into a file.  
# It appears we can't use 'self' references inside of templates

MY_IPADDR=$(curl http://169.254.169.254/1.0/meta-data/local-ipv4)

cat >/tmp/vault-config.json <<EOF
storage "consul" {
  address = "${MY_IPADDR}:8500"
  path    = "vault"
}

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = 1
}

listener "tcp" {
  address     = "${MY_IPADDR}:8200"
  tls_disable = 1
}

EOF

if [ -f /tmp/upstart.conf ];
then
  echo "Installing Upstart service..."
  sudo mkdir -p /etc/vault.d
  sudo mkdir -p /etc/service
  sudo chown root:root /tmp/upstart.conf
  sudo mv /tmp/upstart.conf /etc/init/vault.conf
  sudo chmod 0644 /etc/init/vault.conf
  sudo chmod 0644 /etc/service/vault
else
  echo "Installing Systemd service..."
  sudo mkdir -p /etc/sysconfig
  sudo mkdir -p /etc/systemd/system/vault.d
  sudo chown root:root /tmp/vault.service
  sudo mv /tmp/vault.service /etc/systemd/system/vault.service
  sudo chmod 0644 /etc/systemd/system/vault.service
  sudo mv /tmp/vault-config.json /usr/local/etc/vault-config.json
  # Store run time flags in here if needbe
  # sudo chown root:root /etc/sysconfig/vault
  # sudo chmod 0644 /etc/sysconfig/vault
fi

# Start Vault
# sudo start vault

# Fix up root's environment .bashrc file so we can run vault commands
# this fails, presumably because of some sudo restriction over ssh
# sudo echo "export VAULT_ADDR=http://127.0.0.1:8200" >> /root/.bashrc