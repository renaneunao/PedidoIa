#!/bin/bash

# Script de deploy manual
# Uso: ./scripts/deploy.sh

set -e

# Configurações
VPS_HOST="srv1180349.hstgr.cloud"
VPS_USER="root"
PROJECT_DIR="/opt/pedidoia"

echo "🚀 Iniciando deploy para VPS..."

# Copiar arquivos para o VPS
echo "📦 Copiando arquivos..."
scp docker-compose.yaml ${VPS_USER}@${VPS_HOST}:${PROJECT_DIR}/
scp .env.example ${VPS_USER}@${VPS_HOST}:${PROJECT_DIR}/.env

# Executar deploy no VPS
echo "🔄 Executando deploy no VPS..."
ssh ${VPS_USER}@${VPS_HOST} << 'ENDSSH'
    cd /opt/pedidoia
    
    # Pull das imagens
    docker-compose pull
    
    # Parar containers
    docker-compose down
    
    # Iniciar containers
    docker-compose up -d
    
    # Verificar status
    docker-compose ps
    
    echo "✅ Deploy concluído!"
ENDSSH

echo "✅ Deploy finalizado com sucesso!"
echo "🌐 Acesse:"
echo "  - WAHA: http://${VPS_HOST}:3000"
echo "  - n8n: http://${VPS_HOST}:5678"
