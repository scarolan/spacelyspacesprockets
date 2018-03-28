#!/usr/bin/env bash
set -e

echo "Installing dependencies..."
if [ -x "$(command -v apt-get)" ]; then
  sudo su -s /bin/bash -c 'sleep 30 && apt-get update && apt-get install unzip' root
else
  # This takes forever
  # sudo yum update -y
  sudo yum install -y unzip wget
fi

echo "Fetching Consul..."
CONSUL=1.0.0
cd /tmp
wget https://releases.hashicorp.com/consul/${CONSUL}/consul_${CONSUL}_linux_amd64.zip -O consul.zip --quiet

echo "Installing Consul..."
unzip consul.zip >/dev/null
chmod +x consul
sudo mv consul /usr/local/bin/consul
sudo mkdir -p /opt/consul/data

# Read from the file we created
IPADDR=$(cat /tmp/my_ipaddress | tr -d '\n')
NODENAME=$(cat /tmp/nodename | tr -d '\n')

# Here we set the flags for consul to run as a client instead of a server.
cat >/tmp/consul_flags << EOF
CONSUL_FLAGS="-client=$IPADDR -node=${NODENAME} -retry-join 'provider=aws tag_key=ConsulRole tag_value=Server' -data-dir=/opt/consul/data -enable-script-checks=true -config-dir=/etc/systemd/system/consul.d"
EOF

if [ -f /tmp/upstart.conf ];
then
  echo "Installing Upstart service..."
  sudo mkdir -p /etc/consul.d
  sudo mkdir -p /etc/service
  sudo chown root:root /tmp/upstart.conf
  sudo mv /tmp/upstart.conf /etc/init/consul.conf
  sudo chmod 0644 /etc/init/consul.conf
  sudo mv /tmp/consul_flags /etc/service/consul
  sudo chmod 0644 /etc/service/consul
else
  echo "Installing Systemd service..."
  sudo mkdir -p /etc/sysconfig
  sudo mkdir -p /etc/systemd/system/consul.d
  # This is sloppy but it works on both Ubuntu and Centos
  # Provisioning user has to be able to write to this dir
  sudo chmod 777 /etc/systemd/system/consul.d
  sudo chown root:root /tmp/consul.service
  sudo mv /tmp/consul.service /etc/systemd/system/consul.service
  sudo chmod 0644 /etc/systemd/system/consul.service
  sudo mv /tmp/consul_flags /etc/sysconfig/consul
  sudo chown root:root /etc/sysconfig/consul
  sudo chmod 0644 /etc/sysconfig/consul
fi
