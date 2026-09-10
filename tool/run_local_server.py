#!/usr/bin/env python3
"""Run the companion server with a valid development TLS certificate."""
import argparse
import os
from pathlib import Path
import subprocess
import sys

parser = argparse.ArgumentParser()
parser.add_argument('--server', type=Path, default=Path.home() / 'rustProject/saviour_server')
parser.add_argument('--port', type=int, default=8081)
parser.add_argument('--renew-cert', action='store_true', help='Regenerate the local certificate')
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
tls = root / '.local-server'
tls.mkdir(exist_ok=True)
cert, key = tls / 'cert.pem', tls / 'key.pem'
if args.renew_cert or not cert.exists() or not key.exists():
    san = ['DNS:localhost', 'IP:127.0.0.1', 'IP:10.0.2.2']
    san.extend(f'IP:192.168.1.{host}' for host in range(1, 101))
    subprocess.run(['openssl', 'req', '-x509', '-newkey', 'rsa:2048', '-nodes',
                    '-keyout', str(key), '-out', str(cert), '-days', '30', '-subj', '/CN=localhost',
                    '-addext', 'basicConstraints=critical,CA:FALSE',
                    '-addext', 'keyUsage=critical,digitalSignature,keyEncipherment',
                    '-addext', 'extendedKeyUsage=serverAuth',
                    '-addext', f"subjectAltName={','.join(san)}"], check=True)
    key.chmod(0o600)
subprocess.run([sys.executable, str(root / 'tool/configure_server.py'), '--ca', str(cert),
                '--address', f'127.0.0.1:{args.port}'], check=True)
os.chdir(args.server)
env = dict(os.environ, PORT=str(args.port), TLS_CERTIFICATE=str(cert), TLS_PRIVATE_KEY=str(key))
os.execvpe('cargo', ['cargo', 'run'], env)
