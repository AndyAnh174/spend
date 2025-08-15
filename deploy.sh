#!/bin/bash

# Deploy script for Ubuntu server with Docker + Nginx
# Usage: ./deploy.sh [domain_name] [email]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DOMAIN_NAME=${1:-"your-domain.com"}
SSL_EMAIL=${2:-"admin@your-domain.com"}
PROJECT_NAME="spend-for-andyanh"

echo -e "${GREEN}🚀 Deploying Spend Management App to Ubuntu Server${NC}"
echo "Domain: $DOMAIN_NAME"
echo "Email: $SSL_EMAIL"
echo ""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}❌ Please don't run as root. Use a user with sudo privileges.${NC}"
   exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}📦 Installing Docker...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo -e "${GREEN}✅ Docker installed. Please log out and log back in.${NC}"
    exit 0
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}📦 Installing Docker Compose...${NC}"
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}✅ Docker Compose installed.${NC}"
fi

# Create project directory
echo -e "${YELLOW}📁 Setting up project directory...${NC}"
mkdir -p ~/$PROJECT_NAME
cd ~/$PROJECT_NAME

# Create necessary directories
mkdir -p nginx/ssl nginx/logs nginx/webroot

# Create .env file for production
echo -e "${YELLOW}⚙️  Creating environment configuration...${NC}"
cat > .env << EOF
# Production Environment Variables
DOMAIN_NAME=$DOMAIN_NAME
SSL_EMAIL=$SSL_EMAIL

# Database
MONGO_PASSWORD=$(openssl rand -base64 32)

# JWT Secret
JWT_SECRET=$(openssl rand -base64 64)

# Remote Ollama Configuration
OLLAMA_URL=http://olla.hcmutertic.com
AI_MODEL=deepseek-r1:7b

# Frontend URLs (will be updated after SSL setup)
REACT_APP_API_URL=https://$DOMAIN_NAME/api
REACT_APP_AI_SERVICE_URL=https://$DOMAIN_NAME/ai
EOF

echo -e "${GREEN}✅ Environment file created.${NC}"

# Update nginx configuration with domain
echo -e "${YELLOW}🔧 Updating Nginx configuration...${NC}"
sed -i "s/your-domain.com/$DOMAIN_NAME/g" nginx/nginx.conf

# Build and start services
echo -e "${YELLOW}🐳 Building and starting Docker containers...${NC}"
docker-compose -f docker-compose.prod.yml up -d --build

# Wait for services to be ready
echo -e "${YELLOW}⏳ Waiting for services to start...${NC}"
sleep 30

# Check if services are running
echo -e "${YELLOW}🔍 Checking service status...${NC}"
docker-compose -f docker-compose.prod.yml ps

# Get SSL certificate
echo -e "${YELLOW}🔒 Obtaining SSL certificate...${NC}"
docker-compose -f docker-compose.prod.yml run --rm certbot

# Reload nginx with SSL
echo -e "${YELLOW}🔄 Reloading Nginx with SSL...${NC}"
docker-compose -f docker-compose.prod.yml restart nginx

# Create SSL renewal script
echo -e "${YELLOW}📝 Creating SSL renewal script...${NC}"
cat > renew-ssl.sh << 'EOF'
#!/bin/bash
cd ~/spend-for-andyanh
docker-compose -f docker-compose.prod.yml run --rm certbot renew
docker-compose -f docker-compose.prod.yml restart nginx
EOF

chmod +x renew-ssl.sh

# Add SSL renewal to crontab
(crontab -l 2>/dev/null; echo "0 12 * * * ~/spend-for-andyanh/renew-ssl.sh") | crontab -

# Create management scripts
echo -e "${YELLOW}📝 Creating management scripts...${NC}"

# Start script
cat > start.sh << 'EOF'
#!/bin/bash
cd ~/spend-for-andyanh
docker-compose -f docker-compose.prod.yml up -d
echo "✅ Services started"
EOF

# Stop script
cat > stop.sh << 'EOF'
#!/bin/bash
cd ~/spend-for-andyanh
docker-compose -f docker-compose.prod.yml down
echo "✅ Services stopped"
EOF

# Restart script
cat > restart.sh << 'EOF'
#!/bin/bash
cd ~/spend-for-andyanh
docker-compose -f docker-compose.prod.yml restart
echo "✅ Services restarted"
EOF

# Logs script
cat > logs.sh << 'EOF'
#!/bin/bash
cd ~/spend-for-andyanh
docker-compose -f docker-compose.prod.yml logs -f
EOF

# Status script
cat > status.sh << 'EOF'
#!/bin/bash
cd ~/spend-for-andyanh
docker-compose -f docker-compose.prod.yml ps
echo ""
echo "📊 Resource usage:"
docker stats --no-stream
EOF

chmod +x start.sh stop.sh restart.sh logs.sh status.sh

# Final status check
echo -e "${YELLOW}🔍 Final status check...${NC}"
sleep 10

# Check if services are responding
echo -e "${YELLOW}🌐 Testing endpoints...${NC}"

if curl -f -s https://$DOMAIN_NAME/health > /dev/null; then
    echo -e "${GREEN}✅ Frontend is accessible${NC}"
else
    echo -e "${RED}❌ Frontend is not accessible${NC}"
fi

if curl -f -s https://$DOMAIN_NAME/api/health > /dev/null; then
    echo -e "${GREEN}✅ Backend API is accessible${NC}"
else
    echo -e "${RED}❌ Backend API is not accessible${NC}"
fi

if curl -f -s https://$DOMAIN_NAME/ai/health > /dev/null; then
    echo -e "${GREEN}✅ AI Service is accessible${NC}"
else
    echo -e "${RED}❌ AI Service is not accessible${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo ""
echo -e "${YELLOW}📋 Management Commands:${NC}"
echo "  ./start.sh    - Start all services"
echo "  ./stop.sh     - Stop all services"
echo "  ./restart.sh  - Restart all services"
echo "  ./logs.sh     - View logs"
echo "  ./status.sh   - Check status"
echo "  ./renew-ssl.sh - Renew SSL certificate"
echo ""
echo -e "${YELLOW}🌐 Access URLs:${NC}"
echo "  Frontend:     https://$DOMAIN_NAME"
echo "  Backend API:  https://$DOMAIN_NAME/api"
echo "  AI Service:   https://$DOMAIN_NAME/ai"
echo ""
echo -e "${YELLOW}📁 Project location: ~/$PROJECT_NAME${NC}"
echo -e "${YELLOW}📄 Environment file: ~/$PROJECT_NAME/.env${NC}"
echo ""
echo -e "${GREEN}✅ SSL certificate will auto-renew daily at 12:00 PM${NC}"
