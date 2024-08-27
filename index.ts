import express from 'express';
import path from 'path';

const app = express();
const port = 3000;

// Serve the financial app public files
app.use('/financial-app', express.static(path.join(__dirname, 'financial-app/public')));

// Serve the root financial-app index.html directly
app.get('/financial-app', (req, res) => {
  res.sendFile(path.join(__dirname, 'financial-app/public/index.html'));
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
