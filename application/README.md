# LaunchPad API

LaunchPad API is the intentionally simple Node.js/Express workload for the AWS Production Platform portfolio project.

## Local setup

Copy `.env.example` to `.env` and configure the local PostgreSQL connection.

```bash
npm install
npm test
npm run lint
npm start
```

The API exposes:

- `GET /health`
- `GET /api/users`
- `POST /api/users`
- `GET /api/users/:id`
- `DELETE /api/users/:id`

Initialize the local database using `sql/schema.sql`.
