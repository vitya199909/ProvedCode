#!/bin/bash
set -e

# Set SELinux to permissive mode
echo "Setting SELinux to permissive mode..."
sudo setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/selinux/config

# Install Node.js and dependencies
echo "Installing Node.js and dependencies..."
sudo dnf install -y curl git gcc-c++ make
curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo dnf install -y nodejs

# Setup application
cd /home/vagrant/frontend
sudo chown -R vagrant:vagrant /home/vagrant/frontend
sudo -u vagrant bash << 'EOF'
    cd /home/vagrant/frontend
    npm install --legacy-peer-deps
EOF

# Configure firewall
echo "Configuring firewall..."
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --reload

# Setup systemd service
cat > /etc/systemd/system/frontend.service << 'SERVICEEOF'
[Unit]
Description=React Frontend (npm start)
After=network.target

[Service]
Type=simple
User=vagrant
WorkingDirectory=/home/vagrant/frontend
ExecStart=/usr/bin/npm start
Restart=always
Environment=CI=false
Environment=HOST=0.0.0.0
Environment=REACT_APP_BASE_URL=http://localhost:8080

[Install]
WantedBy=multi-user.target
SERVICEEOF

systemctl daemon-reload
systemctl enable frontend
systemctl restart frontend

echo "Frontend setup completed!"
