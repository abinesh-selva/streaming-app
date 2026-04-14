const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = 3001;
const DB_PATH = path.join(__dirname, 'database.json');

app.use(cors());
app.use(bodyParser.json());

// Helper to read DB
const readDB = () => JSON.parse(fs.readFileSync(DB_PATH, 'utf8'));
// Helper to write DB
const writeDB = (data) => fs.writeFileSync(DB_PATH, JSON.stringify(data, null, 2));

// GET all matches
app.get('/matches', (req, res) => {
  res.json(readDB());
});

// Admin: Update Match (for scores and links)
app.post('/matches/:id', (req, res) => {
  const { id } = req.params;
  const updates = req.body;
  const db = readDB();
  const index = db.findIndex(m => m.id === id);
  
  if (index !== -1) {
    db[index] = { ...db[index], ...updates };
    writeDB(db);
    // Notify SSE clients about the update
    notifyClients(db[index]);
    res.json(db[index]);
  } else {
    res.status(404).json({ error: 'Match not found' });
  }
});

// SSE Implementation for Real-time Scores
let clients = [];
app.get('/events', (req, res) => {
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  res.flushHeaders();

  const clientId = Date.now();
  const newClient = { id: clientId, res };
  clients.push(newClient);

  req.on('close', () => {
    clients = clients.filter(c => c.id !== clientId);
  });
});

function notifyClients(matchUpdate) {
  clients.forEach(c => c.res.write(`data: ${JSON.stringify(matchUpdate)}\n\n`));
}

app.listen(PORT, () => {
  console.log(`Backend Server running at http://localhost:${PORT}`);
});
