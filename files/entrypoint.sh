#!/bin/sh

/app/venv/bin/archivebox init

/app/venv/bin/gunicorn --pythonpath /app/venv/lib/python3.10/site-packages/archivebox -b 0.0.0.0:8000 archivebox.wsgi:application