import express from 'express';
import path from 'path';

const app = express();
const port = 3000;

// Middleware to parse URL-encoded bodies
app.use(express.urlencoded({ extended: true }));

// Serve static files from the "public" directory
app.use(express.static(path.join(__dirname, 'public')));

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public/index.html'));
});

app.post('/calculate', (req, res) => {
  // Parse the input values as floating-point numbers
  const principal = parseFloat(req.body.principal);
  const rate = parseFloat(req.body.rate); // This is the percentage
  const time = parseFloat(req.body.time);

  // Calculate the interest and total amount
  const interest = (principal * rate * time) / 100;
  const total = principal + interest;

  // Send the result back as JSON
  res.json({ interest, total });
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
