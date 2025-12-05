# Script para adicionar chave SSH no VPS
$pubKey = Get-Content "$env:USERPROFILE\.ssh\pedidoia_vps.pub"
$password = "@S0roridade#"
$host = "srv1180349.hstgr.cloud"
$user = "root"

Write-Host "🔑 Adicionando chave SSH no VPS..." -ForegroundColor Yellow

# Criar comando SSH
$sshCommand = @"
mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo '$pubKey' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && echo 'Chave adicionada com sucesso!'
"@

# Usar plink (PuTTY) se disponível, senão instruções manuais
if (Get-Command plink -ErrorAction SilentlyContinue) {
    echo y | plink -pw $password $user@$host $sshCommand
} else {
    Write-Host @"
    
⚠️  Execute o seguinte comando manualmente:

ssh root@srv1180349.hstgr.cloud

Senha: @S0roridade#

Depois execute no VPS:

mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo '$pubKey' >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
exit

"@ -ForegroundColor Cyan
}
