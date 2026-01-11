#!/bin/bash
# Script to run the Flask server

cd "$(dirname "$0")"
source venv/bin/activate
python3 app.py

