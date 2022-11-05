#!/bin/bash

python -m virtualenv venv
echo /venv > .gitignore
echo /.idea >> .gitignore
echo /.vscode >> .gitignore
echo "Created venv and .gitignore"
touch main.py
venv/Scripts/activate
