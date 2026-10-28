"""Compruebo recursos y separación de datos sin modificar el proyecto."""
from pathlib import Path
import json
import re

root = Path(__file__).resolve().parents[1]
files = sorted((root / 'lib').rglob('*.dart'))
patterns = {
    'TextEditingController': r'\bTextEditingController\s*\(',
    'ScrollController': r'\bScrollController\s*\(',
    'PageController': r'\bPageController\s*\(',
    'TabController': r'\bTabController\s*\(',
    'StreamSubscription': r'\bStreamSubscription\b',
    'listen': r'\.listen\s*\(',
}
result = {'recursos': {}, 'pantallas_con_estado': [], 'sql_en_pantallas': []}
for label, pattern in patterns.items():
    matches = []
    for path in files:
        for number, line in enumerate(path.read_text(encoding='utf-8').splitlines(), 1):
            if re.search(pattern, line):
                matches.append({'archivo': path.relative_to(root).as_posix(), 'linea': number})
    result['recursos'][label] = {'cantidad': len(matches), 'ubicaciones': matches}
for path in files:
    text = path.read_text(encoding='utf-8')
    result['pantallas_con_estado'] += re.findall(r'class\s+(\w+)\s+extends\s+StatefulWidget', text)
    if '/screens/' in path.as_posix() and re.search(r'CREATE\s+TABLE|ALTER\s+TABLE|rawQuery\s*\(|rawExecute\s*\(', text, re.I):
        result['sql_en_pantallas'].append(path.relative_to(root).as_posix())
result['archivos_dart_revisados'] = len(files)
print(json.dumps(result, ensure_ascii=False, indent=2))
