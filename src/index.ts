import express from 'express';

const app = express();
const port = 3000;

app.get('/', (req, res) => {
  const message = "Hello Mr. Great!";
  
  // Send the response with HTML and CSS to center and style the message and add a text box
  res.send(`
    <html>
      <head>
        <style>
          body {
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            font-family: Arial, sans-serif;
            background-color: #fff; /* Optional: Set background color */
          }
          h1 {
            font-size: 48px; /* Big font size */
            color: black; /* Black color */
            font-weight: bold; /* Bold text */
            margin: 0;
          }
          input[type="text"] {
            margin-top: 20px;
            padding: 10px;
            font-size: 24px;
            border: 2px solid #000;
            border-radius: 5px;
            width: 300px;
            text-align: center;
          }
        </style>
      </head>
      <body>
        <h1>${message}</h1>
        <input type="text" placeholder="Go on Mr., say it">
      </body>
    </html>
  `);
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
