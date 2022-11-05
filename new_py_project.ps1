python -m virtualenv venv
Write-Output /venv > .gitignore
Write-Output /.idea >> .gitignore
Write-Output /.vscode >> .gitignore
Write-Output "Created venv and .gitignore"
New-Item ./main.py
venv/Scripts/activate
