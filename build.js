const fs = require('fs');
const path = require('path');

// Copy index.html to financial-app/public
fs.copyFileSync('index.html', path.join('financial-app', 'public', 'index.html'));

console.log('index.html copied to financial-app/public');