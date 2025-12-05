# Script de configuração do GitHub e Docker Hub
# Uso: .\scripts\setup-github.ps1

$ErrorActionPreference = "Stop"

Write-Host "🚀 Configurando GitHub e Docker Hub para PedidoIA..." -ForegroundColor Green

# Variáveis
$DOCKER_USERNAME = Read-Host "Digite seu username do Docker Hub"
$DOCKER_TOKEN = Read-Host "Digite seu token do Docker Hub" -AsSecureString | ConvertFrom-SecureString
$VPS_HOST = "srv1180349.hstgr.cloud"
$VPS_USER = "root"

# Verificar se gh está instalado
$ghPath = "C:\Program Files\GitHub CLI\gh.exe"
if (-not (Test-Path $ghPath)) {
    Write-Host "❌ GitHub CLI não encontrado. Instalando..." -ForegroundColor Red
    winget install --id GitHub.cli
    Write-Host "✅ GitHub CLI instalado. Por favor, reinicie o terminal e execute novamente." -ForegroundColor Green
    exit
}

# Verificar autenticação do GitHub
Write-Host "🔐 Verificando autenticação do GitHub..." -ForegroundColor Yellow
$authStatus = & $ghPath auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "📝 Fazendo login no GitHub..." -ForegroundColor Yellow
    & $ghPath auth login
}

# Criar repositório no GitHub
Write-Host "📦 Criando repositório no GitHub..." -ForegroundColor Yellow
$repoExists = & $ghPath repo view PedidoIa 2>&1
if ($LASTEXITCODE -ne 0) {
    & $ghPath repo create PedidoIa --public --description "Sistema inteligente de atendimento de pedidos de delivery utilizando LLM, WAHA e n8n" --source=. --remote=origin
    Write-Host "✅ Repositório criado com sucesso!" -ForegroundColor Green
} else {
    Write-Host "ℹ️  Repositório já existe" -ForegroundColor Cyan
}

# Gerar chave SSH para o VPS (se não existir)
Write-Host "🔑 Configurando chave SSH para VPS..." -ForegroundColor Yellow
$sshKeyPath = "$env:USERPROFILE\.ssh\pedidoia_vps"
if (-not (Test-Path $sshKeyPath)) {
    ssh-keygen -t ed25519 -f $sshKeyPath -N '""' -C "pedidoia-deploy"
    Write-Host "✅ Chave SSH criada" -ForegroundColor Green
} else {
    Write-Host "ℹ️  Chave SSH já existe" -ForegroundColor Cyan
}

# Ler chave privada SSH
$sshPrivateKey = Get-Content $sshKeyPath -Raw

# Configurar secrets no GitHub
Write-Host "🔐 Configurando secrets no GitHub..." -ForegroundColor Yellow

# DOCKER_USERNAME
Write-Host "  - Configurando DOCKER_USERNAME..." -ForegroundColor Cyan
echo $DOCKER_USERNAME | & $ghPath secret set DOCKER_USERNAME

# DOCKER_TOKEN
Write-Host "  - Configurando DOCKER_TOKEN..." -ForegroundColor Cyan
echo $DOCKER_TOKEN | & $ghPath secret set DOCKER_TOKEN

# VPS_HOST
Write-Host "  - Configurando VPS_HOST..." -ForegroundColor Cyan
echo $VPS_HOST | & $ghPath secret set VPS_HOST

# VPS_USER
Write-Host "  - Configurando VPS_USER..." -ForegroundColor Cyan
echo $VPS_USER | & $ghPath secret set VPS_USER

# VPS_SSH_PRIVATE_KEY
Write-Host "  - Configurando VPS_SSH_PRIVATE_KEY..." -ForegroundColor Cyan
echo $sshPrivateKey | & $ghPath secret set VPS_SSH_PRIVATE_KEY

Write-Host "✅ Secrets configurados com sucesso!" -ForegroundColor Green

# Copiar chave pública para o VPS
Write-Host "📤 Copiando chave SSH para o VPS..." -ForegroundColor Yellow
$sshPublicKey = Get-Content "$sshKeyPath.pub"

Write-Host @"

⚠️  IMPORTANTE: Execute o seguinte comando no VPS para adicionar a chave SSH:

ssh $VPS_USER@$VPS_HOST

Depois execute:
mkdir -p ~/.ssh
echo "$sshPublicKey" >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

"@ -ForegroundColor Yellow

# Inicializar git (se necessário)
if (-not (Test-Path ".git")) {
    Write-Host "📝 Inicializando repositório Git..." -ForegroundColor Yellow
    git init
    git add .
    git commit -m "Initial commit: Setup PedidoIA with WAHA, n8n, PostgreSQL and Redis"
    git branch -M main
    git remote add origin "https://github.com/$DOCKER_USERNAME/PedidoIa.git"
    Write-Host "✅ Git inicializado" -ForegroundColor Green
}

# Push para o GitHub
Write-Host "📤 Fazendo push para o GitHub..." -ForegroundColor Yellow
$pushConfirm = Read-Host "Deseja fazer push agora? (s/n)"
if ($pushConfirm -eq "s") {
    git push -u origin main
    Write-Host "✅ Push realizado com sucesso!" -ForegroundColor Green
}

Write-Host @"

🎉 Configuração concluída!

📋 Próximos passos:
1. Adicione a chave SSH ao VPS (comando acima)
2. Execute o script de setup no VPS: bash scripts/setup-vps.sh
3. Faça push para o GitHub para iniciar o deploy automático
4. Configure o n8n e WAHA conforme o README.md

🔗 Links úteis:
- Repositório: https://github.com/$DOCKER_USERNAME/PedidoIa
- Actions: https://github.com/$DOCKER_USERNAME/PedidoIa/actions
- Docker Hub: https://hub.docker.com/r/$DOCKER_USERNAME/pedidoia

"@ -ForegroundColor Green
