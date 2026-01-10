#!/bin/bash
set -e

# Set SELinux to permissive mode
echo "Setting SELinux to permissive mode..."
sudo setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/selinux/config

# Install Java 17 and Maven
echo "Installing Java 17 and Maven..."
sudo dnf install -y java-17-openjdk java-17-openjdk-devel maven git curl

# Set Java 17 as default
echo "Setting Java 17 as default..."
sudo alternatives --set java /usr/lib/jvm/java-17-openjdk-17.0.13.0.11-3.0.1.el8.x86_64/bin/java || sudo alternatives --set java java-17-openjdk.x86_64
sudo alternatives --set javac /usr/lib/jvm/java-17-openjdk-17.0.13.0.11-3.0.1.el8.x86_64/bin/javac || sudo alternatives --set javac java-17-openjdk.x86_64
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk

# Setup application
cd /home/vagrant/backend
chown -R vagrant:vagrant /home/vagrant/backend
chmod +x mvnw
sudo -u vagrant bash << 'EOF'
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
    export PATH=$JAVA_HOME/bin:$PATH
    cd /home/vagrant/backend
    chmod +x mvnw
    java -version
    ./mvnw clean package
EOF

# Configure firewall
echo "Configuring firewall..."
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload

# Setup systemd service
cat > /etc/systemd/system/backend.service << 'SERVICEEOF'
[Unit]
Description=Spring Boot Backend
After=network.target

[Service]
Type=simple
User=vagrant
WorkingDirectory=/home/vagrant/backend
ExecStart=/usr/bin/java -jar /home/vagrant/backend/target/demo-0.5.0-SNAPSHOT.jar
Restart=always
Environment=SPRING_PROFILES_ACTIVE=prod
Environment=DB_LOGIN=myuser
Environment=DB_PASSWORD=mypassword
Environment=DB_URL=192.168.56.12:5432/mydb
Environment=S3_ACCESS_KEY=test
Environment=S3_SECRET_KEY=test
Environment=S3_REGION=us-west-1
Environment=BUCKET=my-bucket
Environment=EMAIL_USER=""
Environment=EMAIL_PASSWORD=""

[Install]
WantedBy=multi-user.target
SERVICEEOF

systemctl daemon-reload
systemctl enable backend
systemctl restart backend

echo "Backend setup completed!"