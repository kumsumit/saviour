#!/usr/bin/env python3
"""Create local Flutter defines using a public server CA certificate (never a key)."""
import argparse
import base64
import json
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--ca', required=True, type=Path)
parser.add_argument('--address', default='127.0.0.1:8080')
parser.add_argument('--name', default='localhost')
args = parser.parse_args()
pem = args.ca.read_text()
if 'PRIVATE KEY' in pem or 'BEGIN CERTIFICATE' not in pem:
    parser.error('--ca must contain public PEM certificates only')
out = Path(__file__).resolve().parents[1] / 'saviour.local.json'
out.write_text(json.dumps({'SAVIOUR_SERVER_ADDRESS': args.address, 'SAVIOUR_SERVER_NAME': args.name, 'SAVIOUR_CA_BASE64': base64.b64encode(pem.encode()).decode()}, indent=2) + '\n')
print(f'Created {out.name}. Run: flutter run --dart-define-from-file={out.name}')
