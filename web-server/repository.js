const { Pool } = require("pg");

const db = new Pool({
  user: "myuser",
  host: "10.0.0.7",
  database: "mydatabase",
  password: "mypassword",
  port: 5432,
});

async function addScore(name, score) {
  const queryText =
    "INSERT INTO leaderboard (name, score) VALUES ($1, $2) RETURNING *";
  const res = await db.query(queryText, [name, score]);
  return res.rows[0];
}

async function getLeaderboard() {
  const queryText = "SELECT * FROM leaderboard ORDER BY score DESC LIMIT 10";
  const res = await db.query(queryText);
  return res.rows;
}

async function createDatabase() {
    const queryText = `
        CREATE TABLE leaderboard (
        id SERIAL PRIMARY KEY,
        name TEXT NOT NULL,
        score INTEGER NOT NULL
        );
    `;
    await db.query(queryText);
}

const query = (text, params) => pool.query(text, params);

module.exports = {
  addScore,
  getLeaderboard,
  createDatabase,
  query,
};
