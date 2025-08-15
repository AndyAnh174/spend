# 🚀 Production Deployment Guide - Ubuntu Server

Hướng dẫn deploy dự án Spend Management lên Ubuntu server với Docker + Nginx reverse proxy.

## 📋 Yêu cầu hệ thống

### Server Requirements
- **OS**: Ubuntu 20.04 LTS hoặc 22.04 LTS
- **RAM**: Tối thiểu 2GB (khuyến nghị 4GB+)
- **Storage**: Tối thiểu 20GB
- **Domain**: Domain name với DNS trỏ về server
- **Ports**: 80, 443 (HTTP/HTTPS)

### Software Requirements
- Docker & Docker Compose
- Nginx (reverse proxy)
- Let's Encrypt SSL
- UFW Firewall
- Fail2ban

## 🛠️ Setup Server

### Bước 1: Chuẩn bị server
```bash
# SSH vào server
ssh user@your-server-ip

# Chạy script setup
chmod +x server-setup.sh
./server-setup.sh
```

### Bước 2: Copy project files
```bash
# Từ máy local, copy files lên server
scp -r . user@your-server-ip:~/spend-for-andyanh/

# Hoặc clone từ git
cd ~/spend-for-andyanh
git clone <your-repo-url> .
```

### Bước 3: Cấu hình domain
```bash
# Edit nginx config
nano nginx/nginx.conf

# Thay đổi domain name
# Từ: your-domain.com
# Thành: your-actual-domain.com
```

### Bước 4: Deploy
```bash
# Chạy script deploy
chmod +x deploy.sh
./deploy.sh your-domain.com your-email@domain.com
```

## 🔧 Cấu hình Production

### Environment Variables (.env)
```env
# Production Environment Variables
DOMAIN_NAME=your-domain.com
SSL_EMAIL=admin@your-domain.com

# Database
MONGO_PASSWORD=your-secure-password

# JWT Secret
JWT_SECRET=your-super-secret-jwt-key

# Remote Ollama Configuration
OLLAMA_URL=http://olla.hcmutertic.com
AI_MODEL=deepseek-r1:7b

# Frontend URLs
REACT_APP_API_URL=https://your-domain.com/api
REACT_APP_AI_SERVICE_URL=https://your-domain.com/ai
```

### Nginx Configuration
- **Reverse Proxy**: Chuyển hướng traffic đến các services
- **SSL/TLS**: Let's Encrypt certificate tự động
- **Rate Limiting**: Bảo vệ API khỏi spam
- **Security Headers**: Bảo mật ứng dụng
- **Gzip Compression**: Tối ưu performance

### Docker Services
1. **MongoDB**: Database
2. **Backend**: Golang API
3. **AI Service**: Python AI integration
4. **Frontend**: React app
5. **Nginx**: Reverse proxy
6. **Certbot**: SSL certificate management

## 📊 Monitoring & Management

### Management Scripts
```bash
# Start services
./start.sh

# Stop services
./stop.sh

# Restart services
./restart.sh

# View logs
./logs.sh

# Check status
./status.sh

# Monitor system
./monitor.sh

# Create backup
./backup.sh

# Renew SSL
./renew-ssl.sh
```

### Health Checks
- **Frontend**: `https://your-domain.com/health`
- **Backend**: `https://your-domain.com/api/health`
- **AI Service**: `https://your-domain.com/ai/health`

### Logs Location
- **Nginx**: `~/spend-for-andyanh/nginx/logs/`
- **Docker**: `docker-compose -f docker-compose.prod.yml logs`

## 🔒 Security Features

### Firewall (UFW)
- Port 22 (SSH)
- Port 80 (HTTP)
- Port 443 (HTTPS)
- Deny all other incoming traffic

### Fail2ban
- Bảo vệ SSH khỏi brute force
- Bảo vệ web server
- Auto-ban IP malicious

### SSL/TLS
- Let's Encrypt certificate
- Auto-renewal (crontab)
- HTTP/2 support
- Security headers

### Rate Limiting
- API: 10 requests/second
- AI Service: 5 requests/second
- Burst protection

## 📈 Performance Optimization

### System Optimizations
- **Swap file**: 2GB
- **File descriptors**: 65536
- **Kernel parameters**: Network & memory optimization
- **Log rotation**: Daily rotation, 52 weeks retention

### Docker Optimizations
- **Multi-stage builds**: Giảm image size
- **Non-root users**: Security
- **Health checks**: Auto-restart failed services
- **Resource limits**: Prevent resource exhaustion

### Nginx Optimizations
- **Gzip compression**: Giảm bandwidth
- **Static file caching**: 1 year cache
- **Connection pooling**: Tối ưu connections
- **Load balancing**: Ready for scaling

## 🔄 Backup & Recovery

### Automatic Backups
- **Schedule**: Daily at 2:00 AM
- **Retention**: 7 days
- **Content**: MongoDB data, configs, logs
- **Location**: `~/backups/`

### Manual Backup
```bash
./backup.sh
```

### Restore from Backup
```bash
# Extract backup
tar -xzf spend_backup_YYYYMMDD_HHMMSS.tar.gz

# Restore MongoDB
docker exec -i spend-mongodb-prod mongorestore --drop /tmp/backup

# Restore configs
cp -r nginx_YYYYMMDD_HHMMSS/* nginx/
cp env_YYYYMMDD_HHMMSS .env

# Restart services
./restart.sh
```

## 🚨 Troubleshooting

### Common Issues

#### 1. SSL Certificate Issues
```bash
# Check certificate status
sudo certbot certificates

# Renew manually
./renew-ssl.sh

# Check nginx config
docker exec spend-nginx-prod nginx -t
```

#### 2. Service Not Starting
```bash
# Check logs
./logs.sh

# Check status
./status.sh

# Restart specific service
docker-compose -f docker-compose.prod.yml restart backend
```

#### 3. Database Connection Issues
```bash
# Check MongoDB
docker exec spend-mongodb-prod mongo --eval "db.adminCommand('ping')"

# Check network
docker network ls
docker network inspect spend-for-andyanh_spend-network
```

#### 4. High Resource Usage
```bash
# Monitor resources
htop
docker stats

# Check disk space
df -h
docker system df
```

### Log Analysis
```bash
# Nginx access logs
tail -f nginx/logs/access.log

# Nginx error logs
tail -f nginx/logs/error.log

# Application logs
docker-compose -f docker-compose.prod.yml logs -f backend
```

## 📞 Support

### Emergency Contacts
- **Server Issues**: Check `./monitor.sh`
- **Application Issues**: Check `./logs.sh`
- **SSL Issues**: Check `./renew-ssl.sh`

### Useful Commands
```bash
# Quick health check
curl -f https://your-domain.com/health

# Check SSL certificate
openssl s_client -connect your-domain.com:443 -servername your-domain.com

# Check DNS
nslookup your-domain.com

# Check firewall
sudo ufw status
```

## 🔄 Updates & Maintenance

### Update Application
```bash
# Pull latest code
git pull origin main

# Rebuild and restart
docker-compose -f docker-compose.prod.yml up -d --build

# Check status
./status.sh
```

### System Updates
```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Update Docker
sudo curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### SSL Renewal
- **Automatic**: Daily cron job
- **Manual**: `./renew-ssl.sh`
- **Check**: `sudo certbot certificates`

---

**Lưu ý**: Đây là setup production, đảm bảo backup dữ liệu thường xuyên và monitor hệ thống.
