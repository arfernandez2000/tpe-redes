const express = require("express");
var os = require('os');
const { addScore, getLeaderboard, createDatabase } = require("./repository");
const app = express();
app.use(express.json())

var networkInterfaces = os.networkInterfaces();

function getLocalIp() {
  var localIp = "";
  Object.keys(networkInterfaces).forEach((key) => {
    networkInterfaces[key].forEach((network) => {
      if (network.family === "IPv4" && !network.internal) {
        localIp = network.address;
      }
    });
  });
  return localIp;
}

app.get("/leaderboards", async (req, res) => {
  try {
    const leaderboard = await getLeaderboard();
    console.log(getLocalIp())
    leaderboard.ip = getLocalIp();
    res.status(200).json(leaderboard);
  } catch (err) {
    console.error("Error retrieving leaderboard:", err);
    res.status(500).json({ error: "Failed to retrieve leaderboard", stacktrace: err.message, DB_HOST: process.env.DB_HOST });
  }
});

app.post("/scores", async (req, res) => {
  const name = req.body.name;
  const score = req.body.score;
  try {
    await addScore(name, score);
    console.log(getLocalIp())
    res.status(201).send();
  } catch (err) {
    console.error("Error adding score:", err);
    res.status(500).json({ error: "Failed to add score to leaderboard", stacktrace: err.message });
  }
});

app.post("/database", async (req, res) => {
  try {
    await createDatabase();
    res.status(201).send();
  } catch (err) {
    console.error("Error creating database:", err);
    res.status(500).json({ error: "Failed to create database", stacktrace: err.message});
  }
});

const port = 3000;

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
