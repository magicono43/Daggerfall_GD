"""Reproduce the complete pinned DFU holiday adapter; source trees are read only."""
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'reference_material/daggerfall-unity-1.1.1-cve-2025/Assets/Scripts'


def build():
    formula = SOURCE / 'Game/Formulas/FormulaHelper.cs'
    location = SOURCE / 'API/DFLocation.cs'
    text = formula.read_text(encoding='utf-8-sig')
    def numbers(name):
        return [int(v, 16) for v in re.findall(r'0x[0-9A-Fa-f]+', re.search(name + r' = \{(.*?)\};', text, re.S)[1])]
    regions = numbers('regionIndexCelebratingHoliday')
    days = numbers('holidayDaysOfYear')
    enum = re.search(r'enum Holidays\s*\{(.*?)\}', location.read_text(encoding='utf-8-sig'), re.S)[1]
    names = re.findall(r'^\s*(\w+)\s*,', enum, re.M)[1:54]
    profile = json.loads((ROOT / 'main_project/content/geography/profile.json').read_text())
    mapping = {int(r['ordinal']): r['id'] for r in profile['regions']}
    assert len(names) == len(days) == len(regions) == 53
    hashes = {str(p.relative_to(ROOT)).replace('\\', '/'): hashlib.sha256(p.read_bytes()).hexdigest() for p in (formula, location)}
    entries = []
    for classic, (name, day, region) in enumerate(zip(names, days, regions), 1):
        entries.append({'id': name.lower().replace('_', '-'), 'value': {
            'schema': 'regional-holidays-v1', 'label': name.replace('_', ' '),
            'recurrence': 'annual-fixed-360', 'day': day, 'priority': 54-classic,
            'regions': ['*'] if region == 255 else ['packs/classic#'+mapping[region-1]],
            'classic_id': classic, 'provenance': {'source': 'DFU 1.1.1 pinned local snapshot',
                'sha256': hashes, 'license': 'MIT; scripts/rule/DFU_LICENSE.txt',
                'adapter': {'holiday': classic, 'region_byte': region, 'day': day},
                'differences': 'All matches; priority desc then stable ID; no day-355 cutoff. Old Life unused source enum excluded.'}}})
    return {'domain': 'rule.holidays', 'path': 'annual', 'operation': 'add', 'entries': entries}


if __name__ == '__main__':
    destination = ROOT / 'main_project/content/time/holidays.json'
    destination.write_text(json.dumps(build(), indent=2)+'\n', encoding='utf-8')
    print(f'Wrote 53 source-mapped holidays: {destination}')
