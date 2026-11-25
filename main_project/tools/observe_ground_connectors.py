"""Read-only representative connector investigation; never declares a detector.

Run with explicit ARENA2 and a NEW JSON output. Uses existing independent source
decoders, stable published mappings and original model plane normals.
"""
import hashlib
import json
import math
import pathlib
import struct
import sys
sys.dont_write_bytecode = True
from observe_dungeon_assembly import pin


def observe(root):
    project = pathlib.Path(__file__).resolve().parents[1]
    declared = json.loads((project / 'content/layouts/dungeon_assembly.json').read_text())
    edition = pin(root, 'place-00032')
    raw = (root / 'ARCH3D.BSA').read_bytes()
    count, kind = struct.unpack_from('<HH', raw)
    assert kind == 0x200
    models = {}
    offset = 4
    for n in range(count):
        identity, size = struct.unpack_from('<II', raw, len(raw)-count*8+n*8)
        models[identity] = raw[offset:offset+size]
        offset += size
    examples = []
    for placed in edition['placements']:
        for record in placed['records']:
            if 'model' not in record:
                continue
            model = models[record['model']]
            normal_offset = struct.unpack_from('<i', model, 52)[0]
            planes = struct.unpack_from('<i', model, 8)[0]
            angles = [v*math.tau/2048 for v in record['rotation']]
            inclines = []
            for n in range(planes):
                x, y, z = struct.unpack_from('<iii', model, normal_offset+n*12)
                sine, cosine = math.sin(-angles[1]), math.cos(-angles[1])
                x, z = cosine*x+sine*z, -sine*x+cosine*z
                sine, cosine = math.sin(angles[0]), math.cos(angles[0])
                y, z = cosine*y-sine*z, sine*y+cosine*z
                sine, cosine = math.sin(angles[2]), math.cos(angles[2])
                x, y = cosine*x-sine*y, sine*x+cosine*y
                length = math.sqrt(x*x+y*y+z*z)
                if length and -y/length > 0:
                    degrees = math.degrees(math.acos(min(1, -y/length)))
                    if 45 < degrees < 85:
                        inclines.append({'plane': n, 'degrees': round(degrees, 6)})
            if inclines:
                examples.append({'layout': edition['location'], 'placement': placed['id'],
                                 'block': placed['block'], 'block_name': placed['name'],
                                 'record': record['id'], 'source_address': record['address'],
                                 'model': record['model'], 'model_sha256': record['model_sha256'],
                                 'bounds_metres': record['expected_bounds'], 'inclined_planes': inclines})
    links = declared['layouts']['place-00032']['assembly']['connections']
    return {'schema': 'ground-connector-investigation-v1', 'sources': edition['sources'],
            'layout': edition['location'], 'name': edition['name'],
            'placements': [{'id': p['id'], 'block': p['block'], 'name': p['name'], 'sha256': p['sha256']} for p in edition['placements']],
            'declared_connections': [{'id': v['id'], 'kind': v['kind'], 'a': v['a'], 'b': v['b']} for v in links],
            'steep_model_occurrences': examples,
            'qualification': 'unresolved: geometric inclination and socket paths do not identify required traversal surfaces; no positive/negative semantic labels or scoped exception detector established',
            'policy': 'ordinary slope limit retained; no dungeon exemption installed',
            'annotation_sha256': hashlib.sha256((project/'content/layouts/dungeon_assembly.json').read_bytes()).hexdigest()}


if __name__ == '__main__':
    root, output = map(pathlib.Path, sys.argv[1:3])
    assert root.is_absolute() and not output.exists()
    output.write_text(json.dumps(observe(root), indent=2)+'\n')
