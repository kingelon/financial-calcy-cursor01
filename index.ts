import express from 'express';
import path from 'path';

const app = express();
const port = 3000;

// Serve static files from the root directory
app.use(express.static(path.join(__dirname)));

// Serve the root index.html
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

// Serve Interest Calculator
app.get('/financial-app/interest', (req, res) => {
  res.sendFile(path.join(__dirname, 'financial-app/public/interest.html'));
});

// Serve Loan Amortization Calculator
app.get('/financial-app/loan', (req, res) => {
  res.sendFile(path.join(__dirname, 'financial-app/public/loan.html'));
});

// Start the server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
