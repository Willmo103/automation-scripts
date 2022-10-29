#! /bin/bash

# create a basic .gitignore
touch .gitignore
echo /node_modules >> .gitignore
echo /.vscode >> .gitignore
echo /.idea >> .gitignore
echo /package-lock*.json >> .gitignore

# init npm and install stuff
npm init -y
npm install nodemon -D
touch index.js

# basic script setup
echo "console.log('Hello World!')" >> index.js
nodemon index.js
