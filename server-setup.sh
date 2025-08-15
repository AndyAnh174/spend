#!/bin/bash

# Ubuntu Server Setup Script for Spend Management App
# This script prepares the server for deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Ubuntu Server Setup for Spend Management App${NC}"
echo ""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}❌ Please don't run as root. Use a user with sudo privileges.${NC}"
   exit 1
fi

# Update system
echo -e "${YELLOW}📦 Updating system packages...${NC}"
sudo apt update && sudo apt upgrade -y

# Install essential packages
echo -e "${YELLOW}📦 Installing essential packages...${NC}"
sudo apt install -y \
    curl \
    wget \
    git \
    unzip \
    htop \
    ufw \
    fail2ban \
    nginx \
    certbot \
    python3-certbot-nginx

# Install Docker
echo -e "${YELLOW}🐳 Installing Docker...${NC}"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo -e "${GREEN}✅ Docker installed${NC}"
else
    echo -e "${GREEN}✅ Docker already installed${NC}"
fi

# Install Docker Compose
echo -e "${YELLOW}🐳 Installing Docker Compose...${NC}"
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}✅ Docker Compose installed${NC}"
else
    echo -e "${GREEN}✅ Docker Compose already installed${NC}"
fi

# Configure firewall
echo -e "${YELLOW}🔥 Configuring firewall...${NC}"
sudo ufw --force enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp
echo -e "${GREEN}✅ Firewall configured${NC}"

# Configure fail2ban
echo -e "${YELLOW}🛡️  Configuring fail2ban...${NC}"
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
echo -e "${GREEN}✅ Fail2ban configured${NC}"

# Create swap file if not exists
echo -e "${YELLOW}💾 Checking swap file...${NC}"
if ! swapon --show | grep -q "/swapfile"; then
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    echo -e "${GREEN}✅ Swap file created (2GB)${NC}"
else
    echo -e "${GREEN}✅ Swap file already exists${NC}"
fi

# Optimize system settings
echo -e "${YELLOW}⚙️  Optimizing system settings...${NC}"

# Increase file descriptor limits
echo '* soft nofile 65536' | sudo tee -a /etc/security/limits.conf
echo '* hard nofile 65536' | sudo tee -a /etc/security/limits.conf

# Optimize kernel parameters
cat << EOF | sudo tee -a /etc/sysctl.conf
# Network optimization
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_max_tw_buckets = 5000

# Memory optimization
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
EOF

# Apply kernel parameters
sudo sysctl -p

# Create project directory
echo -e "${YELLOW}📁 Creating project directory...${NC}"
mkdir -p ~/spend-for-andyanh
cd ~/spend-for-andyanh

# Create nginx directories
mkdir -p nginx/ssl nginx/logs nginx/webroot

# Set proper permissions
sudo chown -R $USER:$USER ~/spend-for-andyanh
chmod -R 755 ~/spend-for-andyanh

# Create monitoring script
echo -e "${YELLOW}📝 Creating monitoring script...${NC}"
cat > monitor.sh << 'EOF'
#!/bin/bash
echo "=== System Status ==="
echo "CPU Usage:"
top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1
echo "Memory Usage:"
free -h | grep Mem | awk '{print $3 "/" $2}'
echo "Disk Usage:"
df -h / | tail -1 | awk '{print $5}'
echo "Load Average:"
uptime | awk -F'load average:' '{print $2}'
echo ""
echo "=== Docker Status ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo "=== Service Health ==="
if curl -f -s http://localhost/health > /dev/null; then
    echo "✅ Frontend: OK"
else
    echo "❌ Frontend: DOWN"
fi

if curl -f -s http://localhost/api/health > /dev/null; then
    echo "✅ Backend: OK"
else
    echo "❌ Backend: DOWN"
fi

if curl -f -s http://localhost/ai/health > /dev/null; then
    echo "✅ AI Service: OK"
else
    echo "❌ AI Service: DOWN"
fi
EOF

chmod +x monitor.sh

# Create backup script
echo -e "${YELLOW}📝 Creating backup script...${NC}"
cat > backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/home/$USER/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

echo "Creating backup: $DATE"

# Backup MongoDB data
docker exec spend-mongodb-prod mongodump --out /tmp/backup
docker cp spend-mongodb-prod:/tmp/backup $BACKUP_DIR/mongodb_$DATE
docker exec spend-mongodb-prod rm -rf /tmp/backup

# Backup environment files
cp .env $BACKUP_DIR/env_$DATE

# Backup nginx configs
cp -r nginx $BACKUP_DIR/nginx_$DATE

# Create archive
tar -czf $BACKUP_DIR/spend_backup_$DATE.tar.gz \
    $BACKUP_DIR/mongodb_$DATE \
    $BACKUP_DIR/env_$DATE \
    $BACKUP_DIR/nginx_$DATE

# Clean up
rm -rf $BACKUP_DIR/mongodb_$DATE
rm -rf $BACKUP_DIR/env_$DATE
rm -rf $BACKUP_DIR/nginx_$DATE

echo "Backup completed: $BACKUP_DIR/spend_backup_$DATE.tar.gz"

# Keep only last 7 backups
ls -t $BACKUP_DIR/spend_backup_*.tar.gz | tail -n +8 | xargs -r rm
EOF

chmod +x backup.sh

# Add backup to crontab (daily at 2 AM)
(crontab -l 2>/dev/null; echo "0 2 * * * ~/spend-for-andyanh/backup.sh") | crontab -

# Create log rotation
echo -e "${YELLOW}📝 Setting up log rotation...${NC}"
sudo tee /etc/logrotate.d/spend-app << EOF
/home/$USER/spend-for-andyanh/nginx/logs/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 $USER $USER
    postrotate
        docker exec spend-nginx-prod nginx -s reload
    endscript
}
EOF

# Final instructions
echo ""
echo -e "${GREEN}🎉 Server setup completed successfully!${NC}"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo "1. Copy your project files to ~/spend-for-andyanh/"
echo "2. Update the domain name in nginx/nginx.conf"
echo "3. Run: ./deploy.sh your-domain.com your-email@domain.com"
echo ""
echo -e "${YELLOW}📋 Useful commands:${NC}"
echo "  ./monitor.sh  - Check system and service status"
echo "  ./backup.sh   - Create backup"
echo "  htop          - Monitor system resources"
echo "  docker stats  - Monitor Docker containers"
echo ""
echo -e "${YELLOW}🔧 System optimizations applied:${NC}"
echo "  ✅ Firewall configured (UFW)"
echo "  ✅ Intrusion prevention (Fail2ban)"
echo "  ✅ Swap file (2GB)"
echo "  ✅ File descriptor limits increased"
echo "  ✅ Kernel parameters optimized"
echo "  ✅ Log rotation configured"
echo "  ✅ Daily backups scheduled"
echo ""
echo -e "${GREEN}✅ Server is ready for deployment!${NC}"
