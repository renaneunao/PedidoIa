# 🚀 Instruções de Configuração Final - PedidoIA

## ✅ O que já foi feito:

1. ✅ Repositório GitHub criado: https://github.com/renaneunao/PedidoIa
2. ✅ Secrets configurados no GitHub Actions
3. ✅ Chave SSH gerada para deploy automático
4. ✅ Código enviado para o repositório
5. ✅ GitHub Actions configurado para build automático

## 📋 Próximos Passos:

### 1️⃣ Adicionar Chave SSH no VPS

Conecte ao VPS e execute os seguintes comandos:

```bash
ssh root@srv1180349.hstgr.cloud
```

Depois, execute:

```bash
# Criar diretório SSH se não existir
mkdir -p ~/.ssh

# Adicionar chave pública
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEAurNKUrvNwNa/P4AVMkV43WxS1OrhCtwwc5J/7x9+Q pedidoia-deploy" >> ~/.ssh/authorized_keys

# Configurar permissões corretas
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# Sair
exit
```

### 2️⃣ Testar Conexão SSH

No seu computador local, teste a conexão:

```powershell
ssh -i "$env:USERPROFILE\.ssh\pedidoia_vps" root@srv1180349.hstgr.cloud
```

Se conectar sem pedir senha, está funcionando! ✅

### 3️⃣ Configurar VPS (Primeira vez)

Conecte ao VPS e execute o script de setup:

```bash
ssh root@srv1180349.hstgr.cloud

# Baixar e executar script de configuração
curl -fsSL https://raw.githubusercontent.com/renaneunao/PedidoIa/main/scripts/setup-vps.sh -o setup-vps.sh
chmod +x setup-vps.sh
bash setup-vps.sh
```

### 4️⃣ Copiar docker-compose.yaml para o VPS

```bash
# No VPS, criar diretório
mkdir -p /opt/pedidoia
cd /opt/pedidoia

# Baixar docker-compose.yaml
curl -fsSL https://raw.githubusercontent.com/renaneunao/PedidoIa/main/docker-compose.yaml -o docker-compose.yaml

# Criar arquivo .env
curl -fsSL https://raw.githubusercontent.com/renaneunao/PedidoIa/main/.env.example -o .env

# Editar .env se necessário
nano .env
```

### 5️⃣ Iniciar Aplicação Manualmente (Primeira vez)

```bash
cd /opt/pedidoia
docker-compose up -d
```

### 6️⃣ Verificar Status

```bash
# Ver containers rodando
docker-compose ps

# Ver logs
docker-compose logs -f

# Ver logs de um serviço específico
docker-compose logs -f waha
docker-compose logs -f n8n
```

### 7️⃣ Acessar Serviços

Após iniciar, acesse:

- **WAHA Dashboard**: http://srv1180349.hstgr.cloud:3000/dashboard
  - Login: `admin` / `admin`

- **n8n**: http://srv1180349.hstgr.cloud:5678
  - Login: `admin` / `pedidoia2024`

### 8️⃣ Testar Deploy Automático

Faça qualquer alteração no código e commit:

```bash
# Fazer uma alteração
echo "# Test" >> README.md

# Commit e push
git add .
git commit -m "Test auto deploy"
git push
```

O GitHub Actions irá:
1. ✅ Fazer build da imagem Docker
2. ✅ Enviar para Docker Hub
3. ✅ Conectar no VPS via SSH
4. ✅ Fazer pull da nova imagem
5. ✅ Reiniciar os containers

### 9️⃣ Monitorar GitHub Actions

```bash
# Ver lista de workflows
gh run list

# Ver detalhes de um workflow
gh run view

# Ver logs de um workflow
gh run view --log

# Assistir workflow em tempo real
gh run watch
```

## 🔧 Troubleshooting

### Deploy falha com erro SSH

Se o deploy falhar com erro de SSH:

1. Verifique se a chave foi adicionada corretamente no VPS
2. Teste a conexão SSH manualmente
3. Verifique os logs do GitHub Actions

### Containers não iniciam

```bash
# Ver logs detalhados
docker-compose logs

# Reiniciar containers
docker-compose restart

# Parar e iniciar novamente
docker-compose down
docker-compose up -d
```

### Portas já em uso

Se as portas 3000 ou 5678 já estiverem em uso:

```bash
# Ver o que está usando a porta
netstat -tulpn | grep :3000
netstat -tulpn | grep :5678

# Matar processo se necessário
kill -9 <PID>
```

## 📊 Secrets Configurados

| Secret | Valor |
|--------|-------|
| DOCKER_USERNAME | renaneunao |
| DOCKER_TOKEN | ✅ Configurado |
| VPS_HOST | srv1180349.hstgr.cloud |
| VPS_USER | root |
| VPS_SSH_PRIVATE_KEY | ✅ Configurado |

## 🔗 Links Úteis

- **Repositório**: https://github.com/renaneunao/PedidoIa
- **Actions**: https://github.com/renaneunao/PedidoIa/actions
- **Docker Hub**: https://hub.docker.com/r/renaneunao/pedidoia
- **Documentação WAHA**: https://waha.devlike.pro/docs/
- **Documentação n8n**: https://docs.n8n.io/

## ✅ Checklist Final

- [ ] Chave SSH adicionada no VPS
- [ ] Conexão SSH testada e funcionando
- [ ] Script setup-vps.sh executado no VPS
- [ ] docker-compose.yaml copiado para /opt/pedidoia
- [ ] Containers iniciados manualmente pela primeira vez
- [ ] WAHA acessível em http://srv1180349.hstgr.cloud:3000
- [ ] n8n acessível em http://srv1180349.hstgr.cloud:5678
- [ ] Deploy automático testado e funcionando

---

**Feito com ❤️ por Antonio e Renan**
