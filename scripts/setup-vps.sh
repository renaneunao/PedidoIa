#!/bin/bash

# Script de configuração inicial do VPS
# Uso: ./scripts/setup-vps.sh

set -e

echo "🚀 Iniciando configuração do VPS para PedidoIA..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para print colorido
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then 
    print_error "Por favor, execute como root"
    exit 1
fi

# Atualizar sistema
print_info "Atualizando sistema..."
apt-get update && apt-get upgrade -y
print_success "Sistema atualizado"

# Instalar Docker
print_info "Instalando Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    print_success "Docker instalado"
else
    print_info "Docker já está instalado"
fi

# Instalar Docker Compose
print_info "Instalando Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    print_success "Docker Compose instalado"
else
    print_info "Docker Compose já está instalado"
fi

# Criar diretório do projeto
print_info "Criando diretório do projeto..."
mkdir -p /opt/pedidoia
cd /opt/pedidoia
print_success "Diretório criado: /opt/pedidoia"

# Configurar firewall (UFW)
print_info "Configurando firewall..."
if command -v ufw &> /dev/null; then
    ufw allow 22/tcp    # SSH
    ufw allow 80/tcp    # HTTP
    ufw allow 443/tcp   # HTTPS
    ufw allow 3000/tcp  # WAHA
    ufw allow 5678/tcp  # n8n
    ufw --force enable
    print_success "Firewall configurado"
fi

# Criar arquivo de ambiente
print_info "Criando arquivo .env..."
cat > /opt/pedidoia/.env << 'EOF'
# WAHA Configuration
WAHA_API_KEY=admin
WAHA_API_HOSTNAME=0.0.0.0

# n8n Configuration
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=pedidoia2024
N8N_HOST=0.0.0.0
N8N_PORT=5678
N8N_PROTOCOL=http
WEBHOOK_URL=http://n8n:5678/
GENERIC_TIMEZONE=America/Sao_Paulo

# PostgreSQL Configuration
POSTGRES_USER=pedidoia
POSTGRES_PASSWORD=pedidoia_db_2024
POSTGRES_DB=pedidoia
EOF
print_success "Arquivo .env criado"

# Copiar docker-compose.yaml
print_info "Baixando docker-compose.yaml..."
# Aqui você pode fazer curl do repositório ou copiar manualmente
print_info "Copie o arquivo docker-compose.yaml para /opt/pedidoia/"

# Configurar swap (se necessário)
print_info "Verificando swap..."
if [ $(swapon --show | wc -l) -eq 0 ]; then
    print_info "Criando swap de 2GB..."
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    print_success "Swap configurado"
else
    print_info "Swap já está configurado"
fi

# Configurar log rotation
print_info "Configurando log rotation para Docker..."
cat > /etc/docker/daemon.json << 'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF
systemctl restart docker
print_success "Log rotation configurado"

# Informações finais
echo ""
print_success "🎉 Configuração do VPS concluída!"
echo ""
print_info "Próximos passos:"
echo "1. Copie o arquivo docker-compose.yaml para /opt/pedidoia/"
echo "2. Configure as variáveis de ambiente em /opt/pedidoia/.env"
echo "3. Execute: cd /opt/pedidoia && docker-compose up -d"
echo "4. Acesse WAHA em: http://$(curl -s ifconfig.me):3000"
echo "5. Acesse n8n em: http://$(curl -s ifconfig.me):5678"
echo ""
print_info "Credenciais padrão:"
echo "  WAHA: admin/admin"
echo "  n8n: admin/pedidoia2024"
echo ""
