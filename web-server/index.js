const express = require("express");
const { addScore, getLeaderboard, createDatabase } = require("./repository");
const app = express();
app.use(express.json())

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
  const name = req.body.name;
  const score = req.body.score;
  try {
    await addScore(name, score);
    console.log("Ya lo agregue")
    res.status(201).send();
  } catch (err) {
    console.error("Error adding score:", err);
    res.status(500).json({ error: "Failed to add score to leaderboard" });
  }
});

app.post("/database", async (req, res) => {
  try {
    await createDatabase();
    res.status(201).send();
  } catch (err) {
    console.error("Error creating database:", err);
    res.status(500).json({ error: "Failed to create database"});
  }
});

const port = 3000;

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
