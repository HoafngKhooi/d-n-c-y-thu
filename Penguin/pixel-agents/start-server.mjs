import { PixelAgentsServer } from './server/dist/server/src/server.js';

const server = new PixelAgentsServer({ port: 3000, host: '0.0.0.0' });
server.start().then(() => console.log('Server running on port 3000'));
