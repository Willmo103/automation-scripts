#! /bin/bash

# Create a Gitignore file and add starter stuff
touch .gitignore
echo /venv >> .gitignore
echo /.vscode >> .gitignore
echo /.idea >> .gitignore
echo /__pycache__ >> .gitignore
echo /dev >> .gitignore

# create a virtual env
python -m virtualenv venv
venv/bin/activate
pip install bs4 requests html5lib
pip freeze > requirements.txt

# Setup some sctructure
mkdir dev
touch ./dev/dev.py
touch app.py
touch scraper.py
mkdir utils
touch ./utils/utils.py

# Write the code into the files we created
echo "
import requests as r, os, re
from bs4 import BeautifulSoup as bs
import html5lib


def scrape(url):
    req = r.request('get', url)
    soup = bs(req, 'html5lib')

    item_1 = soup.find('div', 'something')
    print(item_1)

    item_2 = soup.findAll('div', 'something')
    for i, value in enumerate(item_2)
        value = value.getText().strip()
        print(i, value)

    item_3 = soup.find('div', 'something')
    print(item_3)


scrape('   ')
" >> scraper.py


echo "
import requests as r, os, re
from bs4 import BeautifulSoup as bs
import html5lib


def dev_scrape(url):
    req = r.request('get', url)
    soup = bs(req, 'html5lib')

    item_1 = soup.find('div', 'something')
    print(item_1)

    item_2 = soup.findAll('div', 'something')
    for i, value in enumerate(item_2):
        value = value.getText().strip()
        print(i, value)

    item_3 = soup.find('div', 'something')
    print(item_3)


dev_scrape('   ')
" >> dev/dev.py

echo "
import os, platform
from scraper import scrape

os_name = platform.system()
command = ''
if os_name == 'Windows':
    command = 'cls'
else:
    command = 'clear'

urls = []
url = input('Enter Url(s):\n> ')
while url != '':
    if url not in urls:
        urls.append(url)
        url = input('Added, next?\n> ')
    else:
        print('url already in urls!')
        url = ('Enter another url:\n> ')

os.system(command)

for i, item in enumerate(urls):
    print(f'Scraping {i} of {len(urls)}:')
    scrape(item)
" >> app.py

echo "
# utility functions for parsing your data goes here.

def remove_blank_lines(str: str) -> str:
    lines = str.split('\n')
    non_empty = [line for line in lines if line.strip() != ']

    strings = '
    for line in non_empty:
        strings += line + '\n'
    return strings

" >> utils/utils.py
