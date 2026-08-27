jest.mock('../src/db', () => ({
  query: jest.fn()
}));

const request = require('supertest');
const db = require('../src/db');
const app = require('../src/app');

describe('LaunchPad API', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('GET /health returns service health', async () => {
    const response = await request(app).get('/health');

    expect(response.statusCode).toBe(200);
    expect(response.body).toEqual({
      status: 'ok',
      service: 'launchpad-api'
    });
  });

  test('GET /api/users returns users', async () => {
    const users = [
      {
        id: '1',
        name: 'Ada Lovelace',
        email: 'ada@example.com',
        created_at: '2026-01-01T00:00:00.000Z'
      }
    ];

    db.query.mockResolvedValue({ rows: users });

    const response = await request(app).get('/api/users');

    expect(response.statusCode).toBe(200);
    expect(response.body.users).toEqual(users);
  });

  test('POST /api/users creates a user', async () => {
    const user = {
      id: '1',
      name: 'Ada Lovelace',
      email: 'ada@example.com',
      created_at: '2026-01-01T00:00:00.000Z'
    };

    db.query.mockResolvedValue({ rows: [user] });

    const response = await request(app)
      .post('/api/users')
      .send({ name: 'Ada Lovelace', email: 'ADA@example.com' });

    expect(response.statusCode).toBe(201);
    expect(response.body.user).toEqual(user);
    expect(db.query).toHaveBeenCalledWith(
      expect.stringContaining('INSERT INTO users'),
      ['Ada Lovelace', 'ada@example.com']
    );
  });

  test('POST /api/users rejects missing fields', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ name: 'Ada Lovelace' });

    expect(response.statusCode).toBe(400);
    expect(response.body).toEqual({
      error: 'name and email are required'
    });
    expect(db.query).not.toHaveBeenCalled();
  });

  test('GET /api/users/:id returns a user', async () => {
    const user = {
      id: '1',
      name: 'Ada Lovelace',
      email: 'ada@example.com',
      created_at: '2026-01-01T00:00:00.000Z'
    };

    db.query.mockResolvedValue({ rows: [user] });

    const response = await request(app).get('/api/users/1');

    expect(response.statusCode).toBe(200);
    expect(response.body.user).toEqual(user);
  });

  test('GET /api/users/:id returns 404 when user does not exist', async () => {
    db.query.mockResolvedValue({ rows: [] });

    const response = await request(app).get('/api/users/999');

    expect(response.statusCode).toBe(404);
    expect(response.body).toEqual({ error: 'user not found' });
  });

  test('DELETE /api/users/:id deletes a user', async () => {
    db.query.mockResolvedValue({ rows: [{ id: '1' }] });

    const response = await request(app).delete('/api/users/1');

    expect(response.statusCode).toBe(204);
    expect(response.body).toEqual({});
  });
});
