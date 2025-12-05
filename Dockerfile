# Dockerfile para aplicação customizada (se necessário no futuro)
FROM node:18-alpine

WORKDIR /app

# Instalar dependências do sistema
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    curl

# Copiar arquivos de dependências
COPY package*.json ./

# Instalar dependências
RUN npm ci --only=production

# Copiar código da aplicação
COPY . .

# Expor porta
EXPOSE 8080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Comando de inicialização
CMD ["node", "index.js"]
