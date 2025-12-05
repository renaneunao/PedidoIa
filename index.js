const express = require('express');
const app = express();
const PORT = process.env.PORT || 8080;

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'PedidoIA',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'PedidoIA - Sistema inteligente de atendimento de pedidos',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      api: '/api'
    }
  });
});

// API endpoint placeholder
app.get('/api', (req, res) => {
  res.json({
    message: 'API PedidoIA',
    status: 'ready'
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 PedidoIA running on port ${PORT}`);
});
