"""Freeze scenario names from declared cases/source vectors, never run results."""
import hashlib
import json
import pathlib
import re

project = pathlib.Path(__file__).resolve().parents[1]
text = (project/'tests/location_cases.gd').read_text()
source_path = project/'tests/location_source_observation.json'
source = json.loads(source_path.read_text())
functions = dict(re.findall(r'^func (\w+)\([^\n]*\n(.*?)(?=^func |\Z)',text,re.M|re.S))


def names(reload=False,rendered=False):
    selected = ['run'] + ([] if reload else ['native_and_failures','exterior_scaling','operation_checks','source_checks'])
    result = []
    for function in selected:
        result += re.findall(r'check\("([^"\n]+)"\s*,',functions[function])
    reload_only = ['fresh-process geometry version','fresh-process interior geometry version','reconstruction grants no SAVE']
    if not reload: result = [n for n in result if n not in reload_only]
    result += ['source hash '+name for name in source['sources']]
    for model,vectors in source['uv_vectors'].items():
        result += ['packed UV required model '+model]
        for vector in vectors:
            for index in range(3):
                result += [f'packed UV {kind} {model}/{vector["plane"]}/{index}' for kind in ('encoded','independent')]
    for slot in range(256):
        result += [f'ground encoded tile {slot}',f'ground independent tile origin {slot}',f'ground independent image orientation {slot}']
    building = source['buildings'][0]['id']
    for context in ('exterior','interior'):
        for record in source['records']:
            if record['context'] != context or (context == 'interior' and record['building'] != building): continue
            result += [context+' '+kind+' '+record['id'] for kind in ('model binding','model source hash','independent min','independent max')]
            for plane in record['doors']:
                key=f'{source["placement"]}/{record["id"]}/plane-{plane["plane"]}'
                result += [context+' '+kind+' '+key for kind in ('static plane retained','independent static-plane collision','exact hit region','unresolved door never dispatches')]
        result += [context+' independent door inventory']
    for marker in source['markers']:
        if marker['context'] == 'interior' and marker['building'] == building and marker['role'] in ('rest','entry'):
            result += [kind+' '+marker['id'] for kind in ('interior scoped marker role','interior independent marker position','source marker role inventory')]
    if not reload:
        for copy in range(2):
            for record in source['records']:
                if record['context'] != 'exterior': continue
                result += [f'native transformed static-plane hit copy-{copy}/{record["id"]}/plane-{p["plane"]}' for p in record['doors']]
            result += [f'reordered stable building copy-{copy}/'+b['id'] for b in source['buildings']]
        for selection in ('shared','selected'):
            result += [selection+' '+kind for kind in ('geometry assembles','coincident candidate inventory','explicit hit outcome','no traversal dispatch')]
        for role in ('rest','quest'): result += ['authored multiple role '+role,'authored marker at origin '+role]
        for bad in ('missing-binding','missing-selector','required-owner','late-failure'):
            result += [kind+' '+bad for kind in ('reject','preserve geometry','release staging')]
    if rendered: result += ['render capture exterior','render capture interior']
    assert len(set(result)) == len(result), 'Duplicate declared scenarios'
    return sorted(result)


inventory = dict(schema='location-assembly-inventory-v1',fixture='location-assembly-v1',
                 source_observation_sha256=hashlib.sha256(source_path.read_bytes()).hexdigest())
for reload in (False,True):
    for rendered in (False,True):
        mode=('reload-' if reload else '')+('rendered' if rendered else 'headless')
        inventory[mode]=names(reload,rendered)
        print(mode,len(inventory[mode]))
(project/'tests/location_inventory.json').write_text(json.dumps(inventory,indent=2)+'\n')
