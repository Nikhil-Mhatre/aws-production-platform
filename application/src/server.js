const app = require('./app');
const { config } = require('./config');
const { closePool } = require('./db');

const server = app.listen(config.port, () => {
  console.log(`LaunchPad API listening on port ${config.port}`);
});

async function shutdown(signal) {
  console.log(`${signal} received. Shutting down gracefully...`);

  server.close(async () => {
    await closePool();
    process.exit(0);
  });
}

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
