const express = require("express");
const helmet = require("helmet");
const db = require("./db");

const app = express();

app.disable("x-powered-by");
app.use(helmet());
app.use(express.json({ limit: "100kb" }));

app.get("/health", (_req, res) => {
  res.status(200).json({
    status: "ok",
    service: "launchpad-api",
  });
});

app.get("/api/users", async (_req, res, next) => {
  try {
    const result = await db.query("SELECT id, name, email, created_at FROM users ORDER BY id ASC");

    res.status(200).json({ users: result.rows });
  } catch (error) {
    next(error);
  }
});

app.post("/api/users", async (req, res, next) => {
  try {
    const { name, email } = req.body;

    if (!name || typeof name !== "string" || !email || typeof email !== "string") {
      return res.status(400).json({
        error: "name and email are required",
      });
    }

    const result = await db.query(
      `INSERT INTO users (name, email)
       VALUES ($1, $2)
       RETURNING id, name, email, created_at`,
      [name.trim(), email.trim().toLowerCase()],
    );

    return res.status(201).json({ user: result.rows[0] });
  } catch (error) {
    if (error.code === "23505") {
      return res.status(409).json({ error: "email already exists" });
    }

    return next(error);
  }
});

app.get("/api/users/:id", async (req, res, next) => {
  try {
    const id = Number(req.params.id);

    if (!Number.isInteger(id) || id <= 0) {
      return res.status(400).json({ error: "id must be a positive integer" });
    }

    const result = await db.query("SELECT id, name, email, created_at FROM users WHERE id = $1", [
      id,
    ]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "user not found" });
    }

    return res.status(200).json({ user: result.rows[0] });
  } catch (error) {
    return next(error);
  }
});

app.delete("/api/users/:id", async (req, res, next) => {
  try {
    const id = Number(req.params.id);

    if (!Number.isInteger(id) || id <= 0) {
      return res.status(400).json({ error: "id must be a positive integer" });
    }

    const result = await db.query("DELETE FROM users WHERE id = $1 RETURNING id", [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "user not found" });
    }

    return res.status(204).send();
  } catch (error) {
    return next(error);
  }
});

app.use((_req, res) => {
  res.status(404).json({ error: "route not found" });
});

app.use((error, _req, res, _next) => {
  console.error("Unhandled application error:", error);
  res.status(500).json({ error: "internal server error" });
});

module.exports = app;
