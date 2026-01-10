#!/bin/bash
sudo apt update
sudo apt install -y openjdk-17-jdk maven git curl
cd /home/vagrant/backend
chown -R vagrant:vagrant /home/vagrant/backend
chmod +x mvnw
sudo -u vagrant bash << 'EOF'
    cd /home/vagrant/backend
    chmod +x mvnw
    ./mvnw clean package
EOF
cp /vagrant/backend.service /etc/systemd/system/backend.service
systemctl daemon-reload
systemctl enable backend
systemctl restart backend