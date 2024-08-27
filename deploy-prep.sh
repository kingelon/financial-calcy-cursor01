#!/bin/bash

# Copy index.html to 404.html for GitHub Pages routing
cp index.html 404.html

# Update paths in HTML files for GitHub Pages
sed -i 's/\/financial-app\/public\//financial-app\/public\//g' *.html financial-app/public/*.html
sed -i 's/\/financial-app\/interest/financial-app\/public\/interest.html/g' *.html
sed -i 's/\/financial-app\/loan/financial-app\/public\/loan.html/g' *.html

echo "Files prepared for GitHub Pages deployment"
