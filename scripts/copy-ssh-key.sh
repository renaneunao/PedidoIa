#!/bin/bash

# Script para copiar chave SSH para o VPS
# Uso: ./scripts/copy-ssh-key.sh

set -e

VPS_HOST="srv1180349.hstgr.cloud"
VPS_USER="root"

echo "🔑 Copiando chave SSH para o VPS..."

# Verificar se a chave existe
if [ ! -f "$HOME/.ssh/pedidoia_vps.pub" ]; then
    echo "❌ Chave SSH não encontrada. Execute setup-github.ps1 primeiro."
    exit 1
fi

# Copiar chave usando ssh-copy-id
ssh-copy-id -i "$HOME/.ssh/pedidoia_vps.pub" "$VPS_USER@$VPS_HOST"

echo "✅ Chave SSH copiada com sucesso!"
echo "🧪 Testando conexão..."

# Testar conexão
ssh -i "$HOME/.ssh/pedidoia_vps" "$VPS_USER@$VPS_HOST" "echo '✅ Conexão SSH funcionando!'"

echo "🎉 Tudo pronto!"
