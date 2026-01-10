#!/bin/bash
sudo apt update
sudo apt install -y curl git build-essential
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install -y nodejs
cd /home/vagrant/frontend
sudo chown -R vagrant:vagrant /home/vagrant/frontend
sudo -u vagrant bash << 'EOF'
    cd /home/vagrant/frontend
    npm install --legacy-peer-deps
EOF
cp /vagrant/frontend.service /etc/systemd/system/frontend.service
    systemctl daemon-reload
    systemctl enable frontend
    systemctl restart frontend
