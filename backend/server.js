const express = require('express');
const cors = require('cors');
const fs = require('fs').promises;
const path = require('path');

const app = express();
const PORT = 3001;
const DB_PATH = path.join(__dirname, 'database.json');

app.use(cors());
app.use(express.json());

// Only serve admin.html — not the entire backend directory
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'admin.html'));
});
app.get('/admin.html', (req, res) => {
  res.sendFile(path.join(__dirname, 'admin.html'));
});

// Async helpers to avoid blocking the event loop
const readDB = async () => {
  const raw = await fs.readFile(DB_PATH, 'utf8');
  return JSON.parse(raw);
};
const writeDB = async (data) => {
  await fs.writeFile(DB_PATH, JSON.stringify(data, null, 2));
};

// GET all matches
app.get('/matches', async (req, res) => {
  try {
    const db = await readDB();
    res.json(db);
  } catch (e) {
    res.status(500).json({ error: 'Failed to read matches' });
  }
});

// POST create new match
app.post('/matches', async (req, res) => {
  try {
    const db = await readDB();
    const newMatch = { id: `m${Date.now()}`, ...req.body };
    db.push(newMatch);
    await writeDB(db);
    res.status(201).json(newMatch);
  } catch (e) {
    res.status(500).json({ error: 'Failed to create match' });
  }
});

// POST update existing match (scores, links, status)
app.post('/matches/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;
    const db = await readDB();
    const index = db.findIndex(m => m.id === id);

    if (index !== -1) {
      db[index] = { ...db[index], ...updates };
      await writeDB(db);
      notifyClients(db[index]);
      res.json(db[index]);
    } else {
      res.status(404).json({ error: 'Match not found' });
    }
  } catch (e) {
    res.status(500).json({ error: 'Failed to update match' });
  }
});

// DELETE a match
app.delete('/matches/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const db = await readDB();
    const filtered = db.filter(m => m.id !== id);
    if (filtered.length === db.length) {
      return res.status(404).json({ error: 'Match not found' });
    }
    await writeDB(filtered);
    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ error: 'Failed to delete match' });
  }
});

// SSE — real-time score push to all connected clients
let clients = [];

app.get('/events', (req, res) => {
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  res.flushHeaders();

  const clientId = Date.now();
  clients.push({ id: clientId, res });

  // Keep-alive ping every 25s to prevent proxy timeouts
  const keepAlive = setInterval(() => {
    try {
      res.write(': ping\n\n');
    } catch (_) {
      clearInterval(keepAlive);
      clients = clients.filter(c => c.id !== clientId);
    }
  }, 25000);

  req.on('close', () => {
    clearInterval(keepAlive);
    clients = clients.filter(c => c.id !== clientId);
  });
});

function notifyClients(matchUpdate) {
  const payload = `data: ${JSON.stringify(matchUpdate)}\n\n`;
  clients = clients.filter(c => {
    try {
      c.res.write(payload);
      return true;
    } catch (_) {
      return false; // Remove dead connections
    }
  });
}

// Listen on all interfaces so physical devices can reach it
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Backend running at http://0.0.0.0:${PORT}`);
  console.log(`Admin panel:  http://localhost:${PORT}/admin.html`);
});
