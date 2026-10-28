"""Empaqueto únicamente los archivos versionados de mi proyecto Flutter."""
from pathlib import Path
import hashlib
import json
import subprocess
import sys
from zipfile import ZipFile, ZIP_DEFLATED

root = Path(__file__).resolve().parents[1]
destination = Path(sys.argv[1] if len(sys.argv) > 1 else root).resolve()
destination.mkdir(parents=True, exist_ok=True)
name = 'EstradaCuytoBrandonPaolo_ProyectoSesion7.zip'
files = subprocess.check_output(
    ['git', 'ls-files', '-z'], cwd=root
).decode('utf-8').split('\0')
files = [name for name in files if name]
with ZipFile(destination / name, 'w', ZIP_DEFLATED) as archive:
    for relative in files:
        source = root / relative
        if source.is_file():
            archive.write(source, 'habitos_sesion7/' + relative)
payload = (destination / name).read_bytes()
print(json.dumps({
    'archivo': name,
    'archivos_versionados': len(files),
    'bytes': len(payload),
    'sha256': hashlib.sha256(payload).hexdigest(),
}, ensure_ascii=False, indent=2))
