Write-Output /venv > .gitignore
Write-Output .env >> .gitignore
Write-Output /.vscode >> .gitignore
Write-Output /.idea >> .\.gitignore
Write-Output /__pycache__ >> .\.gitignore

python -m virtualenv venv
venv/Scripts/activate
pip install fastapi[all] sqlalchemy passlib[bcrypt] psycopg2 python-jose[cryptography]
pip freeze > requirements.txt

mkdir app
New-Item app/__init__.py

Write-Output 'from fastapi import FastAPI


app = FastAPI()

origins = ["*"]

app.add_middleware(
        CORSMiddleware,
        allow_origins=origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

app.include_router(user.router)
' > app/main.py
