#! /bin/bash

# create a basic .gitignore
echo /node_modules > .gitignore
echo /.vscode >> .gitignore
echo /.idea >> .gitignore
echo package-lock*.json >> .gitignore
echo .env >> .gitignore

# init npm and install stuff
npm init -y
npm install nodemon -D

# basic script setup
echo "console.log('Hello World!')" > index.js
nodemon index.js
