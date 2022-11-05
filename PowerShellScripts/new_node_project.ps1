# create a basic .gitignore
Write-Output /node_modules > .gitignore
Write-Output /.vscode >> .gitignore
Write-Output /.idea >> .gitignore
Write-Output package-lock*.json >> .gitignore
Write-Output .env >> .gitignore

# init npm and install stuff
npm init -y
npm install nodemon -D

# basic script setup
Write-Output "console.log('Hello World!')" > index.js
nodemon index.js
