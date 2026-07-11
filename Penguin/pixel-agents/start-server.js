const { PixelAgentsServer } = require('./server/dist/server/server.js');

// Create server instance
const server = new PixelAgentsServer();

// Start server on port 3000 and bind to all interfaces (0.0.0.0) for public access
server.start({
  host: '0.0.0.0',
  port: 3000
}).then(config => {
  console.log(`Pixel Agents server started on http://${config.host || '0.0.0.0'}:${config.port}`);
  console.log('Server config:', config);
}).catch(error => {
  console.error('Failed to start server:', error);
  process.exit(1);
});
