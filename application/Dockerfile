FROM node:22-alpine

WORKDIR /app

# Enable pnpm through Corepack
RUN corepack enable

# Copy dependency manifests first for better Docker layer caching
COPY package.json pnpm-lock.yaml ./

# Install production dependencies from the lockfile
RUN pnpm install --prod --frozen-lockfile

# Copy application source
COPY src ./src

# Run the application as the non-root node user
USER node

EXPOSE 3000

# Container health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://127.0.0.1:3000/health', res => process.exit(res.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"

CMD ["node", "src/server.js"]
