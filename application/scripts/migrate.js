const fs = require("fs");
const path = require("path");
const { Client } = require("pg");
const { config } = require("../src/config");

const migrationPath = path.join(__dirname, "../migrations/001-create-users.sql");

async function migrate() {
  const sql = fs.readFileSync(migrationPath, "utf8");

  const client = new Client({
    host: config.database.host,
    port: config.database.port,
    database: config.database.name,
    user: config.database.user,
    password: config.database.password,
    ssl: config.database.ssl ? { rejectUnauthorized: false } : undefined,
  });

  try {
    console.log("Connecting to PostgreSQL...");
    await client.connect();

    console.log("Running migration...");
    await client.query(sql);

    console.log("Migration completed successfully.");
  } catch (error) {
    console.error("Migration failed:", error);
    process.exitCode = 1;
  } finally {
    await client.end();
  }
}

migrate();
