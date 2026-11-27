"""Rebuild the replaceable baseline from the pinned, read-only DFU name bank.

No classic artwork is copied. DFU NameGen.txt is MIT-licensed data; retain its
source hash, upstream license and the explicit pattern interpretation.
"""
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
source = ROOT / 'reference_material/daggerfall-unity-1.1.1-cve-2025/Assets/Resources/NameGen.txt'
raw = source.read_bytes()
# The pinned file's unused Monster3 tail is malformed JSON. Parse only the
# eight authorized culture objects independently; never repair source bytes.
text = raw.decode('utf-8-sig')
banks = {}
for match in re.finditer(r'"(Breton|Redguard|Nord|DarkElf|HighElf|WoodElf|Khajiit|Imperial)"\s*:\s*', text):
    banks[match[1]] = json.JSONDecoder().raw_decode(text, match.end())[0]
races = ['breton', 'redguard', 'nord', 'dark-elf', 'high-elf', 'wood-elf', 'khajiit', 'argonian']
bank_ids = ['Breton', 'Redguard', 'Nord', 'DarkElf', 'HighElf', 'WoodElf', 'Khajiit', 'Imperial']
value = {'schema': 'creation-identity-v1', 'banks': {}, 'mappings': {}, 'portraits': {}, 'reflexes': {},
         'provenance': {'source': source.relative_to(ROOT).as_posix(), 'sha256': hashlib.sha256(raw).hexdigest(),
                        'license': 'DFU MIT attribution: content/char/DFU_LICENSE.txt; TES naming metadata, no new asset license grant',
                        'patterns': 'DFU NameHelper first/surname composition; isolated PCG bounded draws; no Unity RNG parity claim',
                        'portraits': 'External classic FACE<gender><race>I0.CIF records 0..9, ART_PAL.COL, transparent index zero'}}
for bank_id in bank_ids:
    bank = banks[bank_id]
    patterns = {}
    for gender, first in [('male', [0, 1]), ('female', [2, 3])]:
        parts = first + [" "] + ([0, 1, 'sen'] if bank_id == 'Nord' else [4, 5])
        patterns[gender] = [{'id': 'full', 'weight': 1, 'parts': parts}]
        if bank_id == 'Redguard':
            patterns[gender] = ([{'id': 'long', 'weight': 3, 'parts': [0, 1, 2, 3]}, {'id': 'short', 'weight': 1, 'parts': [0, 1, 2]}]
                                if gender == 'male' else [{'id': 'full', 'weight': 1, 'parts': [0, 1, 2, 4]}])
    value['banks'][bank_id] = {'sets': [s['parts'] for s in bank['sets']], 'patterns': patterns}
for index, (race, bank) in enumerate(zip(races, bank_ids)):
    for gender in ['male', 'female']:
        key = f'{race}/{gender}'
        value['mappings'][key] = {'bank': bank, 'portraits': key}
        value['portraits'][key] = [{'id': f'classic-{face:02}', 'classic': face,
                                    'target': f'creation.portrait.{race}.{gender}.{face:02}'} for face in range(10)]
for index, option in enumerate(['very-high', 'high', 'average', 'low', 'very-low']):
    value['reflexes'][option] = {'label': option.replace('-', ' ').title(), 'classic': index,
                               'timer_adjustment': 450 * (index-2), 'component_percent': 50-10*(index-2),
                               'practice_q16': 65536-(index-2)*8192}
target = ROOT / 'main_project/content/char/identity.json'
target.write_text(json.dumps({'domain': 'char.identity', 'path': 'policy', 'operation': 'add',
                              'entries': [{'id': 'stock', 'value': value}]}, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
print(target)
