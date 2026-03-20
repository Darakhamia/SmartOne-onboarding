const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

// ── Database setup ──────────────────────────────────────────────────────────
const db = new sqlite3.Database('./smartone.db', (err) => {
  if (err) console.error('DB error:', err);
  else console.log('✅ SQLite connected');
});

db.serialize(() => {
  db.run(`CREATE TABLE IF NOT EXISTS merchants (
    id TEXT PRIMARY KEY,
    company_name TEXT,
    company_id TEXT,
    tin TEXT,
    phone TEXT,
    email TEXT,
    city TEXT,
    retail_type TEXT,
    onboarding_step INTEGER DEFAULT 1,
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
  )`);

  db.run(`CREATE TABLE IF NOT EXISTS transactions (
    id TEXT PRIMARY KEY,
    merchant_id TEXT,
    amount REAL,
    currency TEXT,
    type TEXT,
    status TEXT,
    description TEXT,
    outlet TEXT,
    terminal_id TEXT,
    card_last4 TEXT,
    created_at TEXT
  )`);

  db.run(`CREATE TABLE IF NOT EXISTS onboarding_steps (
    id TEXT PRIMARY KEY,
    merchant_id TEXT,
    step_index INTEGER,
    status TEXT,
    completed_at TEXT,
    UNIQUE(merchant_id, step_index)
  )`);

  // Seed demo merchant
  db.run(`INSERT OR IGNORE INTO merchants
    (id, company_name, company_id, tin, phone, email, city, retail_type, onboarding_step)
    VALUES ('demo', 'Apex Retail Solutions Ltd', 'GB123456789', 'GB987654321',
            '+44 20 7946 0100', 'info@apexretail.co.uk', 'London', 'Retail – General', 4)
  `);

  // Seed sample transactions
  const txns = [
    { id: 'TXN-001', amount: 125.50, currency: 'EUR', type: 'SALE',   status: 'APPROVED',  description: 'Card Payment',    outlet: 'Main Store',  terminal: 'TRM-001', card: '4242', days: 0,  hours: 2  },
    { id: 'TXN-002', amount: 89.99,  currency: 'EUR', type: 'SALE',   status: 'APPROVED',  description: 'Contactless Pay', outlet: 'Branch 1',   terminal: 'TRM-002', card: '1234', days: 0,  hours: 5  },
    { id: 'TXN-003', amount: 250.00, currency: 'GBP', type: 'REFUND', status: 'APPROVED',  description: 'Customer Refund', outlet: 'Main Store',  terminal: 'TRM-001', card: '4242', days: 0,  hours: 8  },
    { id: 'TXN-004', amount: 342.80, currency: 'EUR', type: 'SALE',   status: 'APPROVED',  description: 'Card Payment',    outlet: 'Main Store',  terminal: 'TRM-001', card: '5678', days: 1,  hours: 10 },
    { id: 'TXN-005', amount: 67.00,  currency: 'EUR', type: 'SALE',   status: 'DECLINED',  description: 'Chip & PIN',      outlet: 'Branch 2',   terminal: 'TRM-003', card: '9999', days: 1,  hours: 14 },
    { id: 'TXN-006', amount: 510.00, currency: 'GBP', type: 'SALE',   status: 'APPROVED',  description: 'Tap & Pay',       outlet: 'Main Store',  terminal: 'TRM-001', card: '4242', days: 2,  hours: 9  },
    { id: 'TXN-007', amount: 189.90, currency: 'EUR', type: 'SALE',   status: 'APPROVED',  description: 'Card Payment',    outlet: 'Branch 1',   terminal: 'TRM-002', card: '1234', days: 2,  hours: 16 },
    { id: 'TXN-008', amount: 75.50,  currency: 'EUR', type: 'VOID',   status: 'APPROVED',  description: 'Transaction Void',outlet: 'Branch 2',   terminal: 'TRM-003', card: '3333', days: 3,  hours: 11 },
    { id: 'TXN-009', amount: 420.00, currency: 'EUR', type: 'SALE',   status: 'APPROVED',  description: 'Online Payment',  outlet: 'E-Commerce',  terminal: 'TRM-WEB', card: '2222', days: 3,  hours: 15 },
    { id: 'TXN-010', amount: 55.00,  currency: 'GBP', type: 'SALE',   status: 'APPROVED',  description: 'Contactless',     outlet: 'Main Store',  terminal: 'TRM-001', card: '4242', days: 4,  hours: 8  },
    { id: 'TXN-011', amount: 980.00, currency: 'EUR', type: 'SALE',   status: 'APPROVED',  description: 'Card Payment',    outlet: 'Main Store',  terminal: 'TRM-001', card: '7777', days: 4,  hours: 13 },
    { id: 'TXN-012', amount: 130.00, currency: 'EUR', type: 'REFUND', status: 'APPROVED',  description: 'Partial Refund',  outlet: 'Branch 1',   terminal: 'TRM-002', card: '1234', days: 5,  hours: 10 },
    { id: 'TXN-013', amount: 289.99, currency: 'GBP', type: 'SALE',   status: 'APPROVED',  description: 'Chip & PIN',      outlet: 'Main Store',  terminal: 'TRM-001', card: '4242', days: 5,  hours: 17 },
    { id: 'TXN-014', amount: 44.99,  currency: 'EUR', type: 'SALE',   status: 'DECLINED',  description: 'Tap & Pay',       outlet: 'Branch 2',   terminal: 'TRM-003', card: '8888', days: 6,  hours: 9  },
    { id: 'TXN-015', amount: 670.00, currency: 'EUR', type: 'SALE',   status: 'APPROVED',  description: 'Card Payment',    outlet: 'E-Commerce',  terminal: 'TRM-WEB', card: '6666', days: 6,  hours: 14 },
    { id: 'TXN-016', amount: 199.00, currency: 'EUR', type: 'SALE',   status: 'APPROVED',  description: 'Online Payment',  outlet: 'E-Commerce',  terminal: 'TRM-WEB', card: '2222', days: 7,  hours: 11 },
    { id: 'TXN-017', amount: 350.00, currency: 'GBP', type: 'SALE',   status: 'APPROVED',  description: 'Contactless',     outlet: 'Main Store',  terminal: 'TRM-001', card: '4242', days: 8,  hours: 10 },
    { id: 'TXN-018', amount: 89.00,  currency: 'EUR', type: 'VOID',   status: 'APPROVED',  description: 'Transaction Void',outlet: 'Branch 1',   terminal: 'TRM-002', card: '1234', days: 9,  hours: 14 },
    { id: 'TXN-019', amount: 1250.00,currency: 'EUR', type: 'SALE',   status: 'APPROVED',  description: 'Corporate Card',  outlet: 'Main Store',  terminal: 'TRM-001', card: '5555', days: 10, hours: 15 },
    { id: 'TXN-020', amount: 45.00,  currency: 'EUR', type: 'SALE',   status: 'APPROVED',  description: 'Chip & PIN',      outlet: 'Branch 2',   terminal: 'TRM-003', card: '3333', days: 12, hours: 9  },
  ];

  const now = new Date();
  txns.forEach(t => {
    const ts = new Date(now);
    ts.setDate(ts.getDate() - t.days);
    ts.setHours(ts.getHours() - t.hours);
    db.run(`INSERT OR IGNORE INTO transactions
      (id, merchant_id, amount, currency, type, status, description, outlet, terminal_id, card_last4, created_at)
      VALUES (?, 'demo', ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [t.id, t.amount, t.currency, t.type, t.status, t.description, t.outlet, t.terminal, t.card, ts.toISOString()]
    );
  });
});

// ── Routes ───────────────────────────────────────────────────────────────────

// GET /api/health
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', time: new Date().toISOString() });
});

// GET /api/merchants/:id
app.get('/api/merchants/:id', (req, res) => {
  db.get('SELECT * FROM merchants WHERE id = ?', [req.params.id], (err, row) => {
    if (err) return res.status(500).json({ error: err.message });
    if (!row) return res.status(404).json({ error: 'Merchant not found' });
    res.json(row);
  });
});

// POST /api/merchants
app.post('/api/merchants', (req, res) => {
  const { company_name, company_id, tin, phone, email, city, retail_type } = req.body;
  const id = uuidv4();
  db.run(
    `INSERT INTO merchants (id, company_name, company_id, tin, phone, email, city, retail_type)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    [id, company_name, company_id, tin, phone, email, city, retail_type],
    function (err) {
      if (err) return res.status(500).json({ error: err.message });
      res.status(201).json({ id, message: 'Merchant created' });
    }
  );
});

// PUT /api/merchants/:id
app.put('/api/merchants/:id', (req, res) => {
  const fields = req.body;
  const sets = Object.keys(fields).map(k => `${k} = ?`).join(', ');
  const values = [...Object.values(fields), new Date().toISOString(), req.params.id];
  db.run(
    `UPDATE merchants SET ${sets}, updated_at = ? WHERE id = ?`,
    values,
    function (err) {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ message: 'Updated', changes: this.changes });
    }
  );
});

// GET /api/transactions?merchant_id=demo&type=SALE&limit=50
app.get('/api/transactions', (req, res) => {
  const { merchant_id = 'demo', type, status, limit = 50 } = req.query;
  let sql = 'SELECT * FROM transactions WHERE merchant_id = ?';
  const params = [merchant_id];
  if (type)   { sql += ' AND type = ?';   params.push(type); }
  if (status) { sql += ' AND status = ?'; params.push(status); }
  sql += ' ORDER BY created_at DESC LIMIT ?';
  params.push(parseInt(limit));

  db.all(sql, params, (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

// GET /api/transactions/:id
app.get('/api/transactions/:id', (req, res) => {
  db.get('SELECT * FROM transactions WHERE id = ?', [req.params.id], (err, row) => {
    if (err) return res.status(500).json({ error: err.message });
    if (!row) return res.status(404).json({ error: 'Transaction not found' });
    res.json(row);
  });
});

// POST /api/transactions
app.post('/api/transactions', (req, res) => {
  const { merchant_id, amount, currency, type, status, description, outlet, terminal_id, card_last4 } = req.body;
  const id = 'TXN-' + uuidv4().slice(0, 8).toUpperCase();
  db.run(
    `INSERT INTO transactions (id, merchant_id, amount, currency, type, status, description, outlet, terminal_id, card_last4, created_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [id, merchant_id, amount, currency, type, status, description, outlet, terminal_id, card_last4, new Date().toISOString()],
    function (err) {
      if (err) return res.status(500).json({ error: err.message });
      res.status(201).json({ id, message: 'Transaction created' });
    }
  );
});

// GET /api/stats?merchant_id=demo
app.get('/api/stats', (req, res) => {
  const { merchant_id = 'demo' } = req.query;
  db.all(
    `SELECT
       COUNT(*) as total_count,
       SUM(CASE WHEN type = 'SALE' AND status = 'APPROVED' THEN amount ELSE 0 END) as total_volume,
       SUM(CASE WHEN type = 'REFUND' AND status = 'APPROVED' THEN amount ELSE 0 END) as total_refunds,
       SUM(CASE WHEN status = 'DECLINED' THEN 1 ELSE 0 END) as declined_count,
       currency
     FROM transactions WHERE merchant_id = ?
     GROUP BY currency`,
    [merchant_id],
    (err, rows) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(rows);
    }
  );
});

// ── Start ────────────────────────────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`🚀 SmartOne API running at http://localhost:${PORT}`);
  console.log(`   Health: http://localhost:${PORT}/api/health`);
  console.log(`   Transactions: http://localhost:${PORT}/api/transactions`);
});
