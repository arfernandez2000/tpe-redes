const express = require("express");
const { addScore, getLeaderboard, createDatabase } = require("./repository");
const app = express();

app.get("/leaderboards", async (req, res) => {
  try {
    const leaderboard = await getLeaderboard();
    res.status(200).json(leaderboard);
  } catch (err) {
    console.error("Error retrieving leaderboard:", err);
    res.status(500).json({ error: "Failed to retrieve leaderboard" });
  }
});

app.post("/scores", async (req, res) => {
  const { name, score } = req.body;
  try {
    await addScore(name, score);
    res.status(201);
  } catch (err) {
    console.error("Error adding score:", err);
    res.status(500).json({ error: "Failed to add score to leaderboard" });
  }
});

app.post("/database", async (req, res) => {
  try {
    await createDatabase();
    res.status(201);
  } catch (err) {
    console.error("Error creating database:", err);
    res.status(500).json({ error: "Failed to create database"});
  }
});

const port = 3000;

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
