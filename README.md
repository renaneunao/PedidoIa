# Pedido IA 🍕🤖

Sistema inteligente de atendimento de pedidos de delivery utilizando LLM (Large Language Models), integrado com WAHA (WhatsApp HTTP API) e n8n (automação de workflows).

[![Deploy Status](https://github.com/seu-usuario/PedidoIa/workflows/Build%20and%20Deploy%20to%20VPS/badge.svg)](https://github.com/seu-usuario/PedidoIa/actions)

## 📋 Sobre o Projeto

O **Pedido IA** é uma solução completa e automatizada para atendimento de pedidos de delivery através do WhatsApp. Utilizando inteligência artificial (LLM), o sistema é capaz de:

- ✅ Receber pedidos via WhatsApp de forma natural
- ✅ Processar e entender pedidos usando IA
- ✅ Confirmar pedidos automaticamente
- ✅ Armazenar pedidos em banco de dados
- ✅ Notificar o restaurante sobre novos pedidos
- ✅ Gerenciar múltiplas sessões do WhatsApp

## 🏗️ Arquitetura

```
WhatsApp ←→ WAHA (API) ←→ n8n (Workflows) ←→ LLM/IA ←→ PostgreSQL
                                ↓
                            Redis (Cache)
```

## 🚀 Tecnologias

- **[WAHA](https://waha.devlike.pro/)** - WhatsApp HTTP API para integração
- **[n8n](https://n8n.io/)** - Plataforma no-code/low-code para automação de workflows
- **PostgreSQL** - Banco de dados relacional para armazenar pedidos
- **Redis** - Cache e gerenciamento de filas
- **Docker** - Containerização da aplicação
- **GitHub Actions** - CI/CD automatizado

## 👥 Idealizadores

- **Antonio**
- **Renan**

## 📦 Instalação

### Pré-requisitos

- Docker e Docker Compose instalados
- Conta no Docker Hub
- Servidor VPS (Ubuntu/Debian recomendado)
- Acesso SSH ao VPS

### 1️⃣ Instalação Local (Desenvolvimento)

```bash
# Clonar o repositório
git clone https://github.com/seu-usuario/PedidoIa.git
cd PedidoIa

# Copiar arquivo de ambiente
cp .env.example .env

# Editar variáveis de ambiente
nano .env

# Iniciar containers
docker-compose up -d

# Verificar status
docker-compose ps
```

Acesse:
- **WAHA Dashboard**: http://localhost:3000/dashboard (admin/admin)
- **n8n**: http://localhost:5678 (admin/pedidoia2024)

### 2️⃣ Instalação no VPS (Produção)

```bash
# Conectar ao VPS
ssh root@srv1180349.hstgr.cloud

# Executar script de configuração
bash <(curl -s https://raw.githubusercontent.com/seu-usuario/PedidoIa/main/scripts/setup-vps.sh)

# Copiar docker-compose.yaml para /opt/pedidoia/
# Configurar .env em /opt/pedidoia/

# Iniciar aplicação
cd /opt/pedidoia
docker-compose up -d
```

## 🛠️ Configuração

### Configurar n8n

1. Acesse n8n em `http://seu-vps:5678`
2. Faça login com as credenciais configuradas
3. Vá em **Settings** → **Community Nodes**
4. Instale: `@devlikeapro/n8n-nodes-waha`
5. Vá em **Credentials** → **Add Credential**
6. Selecione **WAHA API**
7. Configure:
   - **Host URL**: `http://waha:3000`
   - **API Key**: `admin`
8. Clique em **Save**

### Configurar WAHA Session

1. Acesse WAHA Dashboard em `http://seu-vps:3000/dashboard`
2. Login: `admin/admin`
3. Clique em **Start New Session**
4. Configure:
   - **Session Name**: `pedidoia-session`
   - **Webhook URL**: (copie do n8n WAHA Trigger)
   - **Events**: Selecione `message`
5. Escaneie o QR Code com WhatsApp
6. Aguarde status **WORKING**

### Configurar GitHub Secrets

Para CI/CD funcionar, configure os seguintes secrets no GitHub:

1. Vá em **Settings** → **Secrets and variables** → **Actions**
2. Adicione os seguintes secrets:

| Secret Name | Valor |
|-------------|-------|
| `DOCKER_USERNAME` | Seu username do Docker Hub |
| `DOCKER_TOKEN` | Token do Docker Hub |
| `VPS_HOST` | srv1180349.hstgr.cloud |
| `VPS_USER` | root |
| `VPS_SSH_PRIVATE_KEY` | Chave SSH privada para acesso ao VPS |

## 📖 Como Usar

### Criar Workflow Básico no n8n

1. **Criar novo workflow**
   - Vá em n8n → **Workflows** → **Add Workflow**

2. **Adicionar WAHA Trigger**
   - Adicione node **WAHA Trigger**
   - Configure para escutar evento `message`
   - Copie a **Webhook URL**

3. **Adicionar processamento (exemplo)**
   - Adicione node **Code** ou **HTTP Request** para processar com LLM
   - Adicione node **PostgreSQL** para salvar pedido

4. **Adicionar resposta**
   - Adicione node **WAHA** → **Send Text Message**
   - Configure para enviar confirmação

5. **Ativar workflow**
   - Clique em **Active**
   - Configure a sessão WAHA com a Webhook URL

### Exemplo de Fluxo

```
1. Cliente: "Quero uma pizza calabresa grande"
   ↓
2. WAHA Trigger recebe mensagem
   ↓
3. LLM processa e extrai: {produto: "pizza calabresa", tamanho: "grande"}
   ↓
4. Salva no PostgreSQL
   ↓
5. Responde: "Pedido confirmado! Pizza calabresa grande. Total: R$ 45,00"
```

## 🔄 Deploy Automático

Toda vez que você fizer push para `main` ou `develop`:

1. GitHub Actions faz build da imagem Docker
2. Push da imagem para Docker Hub
3. Conecta no VPS via SSH
4. Faz pull da nova imagem
5. Reinicia os containers
6. Verifica o status

## 📊 Monitoramento

### Ver logs dos containers

```bash
# Todos os containers
docker-compose logs -f

# Container específico
docker-compose logs -f waha
docker-compose logs -f n8n
```

### Verificar status

```bash
docker-compose ps
```

### Acessar container

```bash
docker-compose exec waha sh
docker-compose exec n8n sh
```

## 🔧 Troubleshooting

### WAHA não conecta ao WhatsApp

1. Verifique se a sessão está ativa
2. Tente reiniciar a sessão
3. Verifique os logs: `docker-compose logs waha`

### n8n não recebe webhooks

1. Verifique se a Webhook URL está correta na sessão WAHA
2. Verifique se o workflow está ativo
3. Teste a conectividade: `curl http://waha:3000/health`

### Deploy falha no GitHub Actions

1. Verifique se todos os secrets estão configurados
2. Verifique se a chave SSH está correta
3. Verifique os logs do Actions

## 🤝 Contribuindo

Contribuições são bem-vindas! Para contribuir:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 📞 Contato

Para dúvidas ou sugestões, entre em contato com os idealizadores do projeto.

## 🔗 Links Úteis

- [Documentação WAHA](https://waha.devlike.pro/docs/)
- [Documentação n8n](https://docs.n8n.io/)
- [WAHA + n8n Guide](https://waha.devlike.pro/blog/waha-n8n/)
- [WAHA n8n Templates](https://waha-n8n-templates.devlike.pro/)

---

Feito com ❤️ por Antonio e Renan
