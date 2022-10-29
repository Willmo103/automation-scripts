# create a basic .gitignore
New-Item .gitignore
Write-Output /node_modules >> .gitignore
Write-Output /.vscode >> .gitignore
Write-Output /.idea >> .gitignore
Write-Output /package-lock*.json >> .gitignore

# init npm and install stuff
npm init -y
npm install nodemon -D
New-Item index.js

# basic script setup
Write-Output "console.log('Hello World!')" >> index.js
nodemon index.js
