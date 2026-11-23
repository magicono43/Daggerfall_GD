"""Independent read-only RDB/MAPS/ARCH3D observations for IMP-061.

No runtime imports or definition allocation. Explicit source and NEW output only.
"""
import hashlib
import json
import pathlib
import struct
import sys
import math
sys.dont_write_bytecode = True
from observe_layout_source import archive, u16, u32, i32


def rdb(entry):
    b = entry['payload']
    width, height = struct.unpack_from('<II', b, 4)
    records = []
    for root in range(width * height):
        at = i32(b, 9532 + root * 4)
        seen = set()
        while at >= 0:
            assert at not in seen
            seen.add(at)
            nxt, previous, x, y, z, kind, resource = struct.unpack_from('<iiiiiBI', b, at)
            record = dict(address=at, position=[x, y, z], kind=kind)
            if kind == 1:
                rotation = list(struct.unpack_from('<iii', b, resource))
                index = u16(b, resource + 12)
                model = b[20 + index * 8:25 + index * 8].split(b'\0')[0]
                record.update(model=int(model), rotation=rotation, description=b[25+index*8:28+index*8].split(b'\0')[0].decode('ascii'))
                action = i32(b, resource + 19)
                if action > 0:
                    axis, duration, magnitude, target, action_kind = struct.unpack_from('<BHH i B', b, action)
                    record['action'] = dict(axis=axis, kind=action_kind, target=target)
            elif kind == 3:
                record['texture'] = u16(b, resource) >> 7
            records.append(record)
            at = nxt
    return records


def observe(root):
    project = pathlib.Path(__file__).resolve().parents[1]
    profile = json.loads((project / 'content/layouts/profile.json').read_text())
    _, maps = archive(root / 'MAPS.BSA')
    _, blocks = archive(root / 'BLOCKS.BSA')
    by_name = {b['name']: b for b in blocks}
    locations = []
    for m in profile['locations']:
        b = maps[m['region'] * 4 + 1]['payload']
        if not b:
            continue
        count = u32(b, 0)
        for n in range(count):
            address, flag, loc = struct.unpack_from('<IHH', b, 4 + 8 * n)
            if loc != m['location_id']:
                continue
            at = 4 + count * 8 + address
            at += 4 + u32(b, at) * 6 + 112
            size = u16(b, at + 10)
            placements = []
            valid = True
            for j in range(size):
                x, z, bits = struct.unpack_from('<bbH', b, at + 17 + j * 4)
                name = f'{"NWLSBM"[bits >> 11]}{bits & 1023:07d}.RDB'
                try:
                    records = rdb(by_name[name])
                    valid &= all(r.get('action', {}).get('axis', 0) <= 6 or r.get('action', {}).get('kind') not in (1, 8) for r in records)
                    valid &= all(r.get('action', {}).get('kind', 0) in (0,1,2,3,4,5,6,7,8,9,11,12,14,16,17,18,20,21,22,23,24,25,26,28,29,30,31,99) for r in records)
                except (ValueError, AssertionError, KeyError):
                    valid = False
                    records = []
                placements.append(dict(name=name, grid=[x,z], records=len(records)))
            if valid and 2 <= size <= 8:
                locations.append(dict(id=m['id'], region=m['region'], ordinal=m['ordinal'], placements=placements))
    return dict(schema='dungeon-candidates-v1', candidates=locations[:30])


def pin(root, location):
    project = pathlib.Path(__file__).resolve().parents[1]
    profile = json.loads((project / 'content/layouts/profile.json').read_text())
    mapping = next(m for m in profile['locations'] if m['id'] == location)
    _, maps = archive(root / 'MAPS.BSA')
    _, blocks = archive(root / 'BLOCKS.BSA')
    by_name = {b['name']: b for b in blocks}
    block_keys = {b['name']: b for b in profile['blocks']}
    models_bytes = (root / 'ARCH3D.BSA').read_bytes()
    count, kind = struct.unpack_from('<HH', models_bytes)
    assert kind == 0x200
    models = {}
    offset = 4
    for n in range(count):
        key, size = struct.unpack_from('<II', models_bytes, len(models_bytes)-count*8+n*8)
        models.setdefault(key, []).append(models_bytes[offset:offset+size])
        offset += size
    b = maps[mapping['region']*4+1]['payload']
    count = u32(b, 0)
    matches = [struct.unpack_from('<IHH', b, 4+n*8) for n in range(count) if u16(b, 10+n*8) == mapping['location_id']]
    assert len(matches) == 1
    at = 4+count*8+matches[0][0]
    at += 4+u32(b, at)*6+112
    placements = []
    textures = set()
    for j in range(u16(b, at+10)):
        x, z, bits = struct.unpack_from('<bbH', b, at+17+j*4)
        name = f'{"NWLSBM"[bits >> 11]}{bits & 1023:07d}.RDB'
        entry = by_name[name]
        key = block_keys[name]
        records = rdb(entry)
        for record in records:
            record['id'] = key['records'][str(record['address'])]
            if 'texture' in record:
                textures.add(record['texture'])
            if 'model' not in record:
                continue
            assert len(models[record['model']]) == 1
            model = models[record['model']][0]
            n = i32(model, 4)
            start = i32(model, 48)
            points = [struct.unpack_from('<iii', model, start+i*12) for i in range(n)]
            face_at = i32(model, 60)
            first_indices = []
            used = set()
            for plane in range(i32(model, 8)):
                vertices = model[face_at]
                for vertex in range(vertices):
                    address = i32(model, face_at+8+vertex*8)
                    if model[:4] == b'v2.5':
                        address *= 3
                    assert address % 12 == 0
                    used.add(address//12)
                    if plane == 0:
                        first_indices.append(address//12)
                face_at += 8+vertices*8
            angles = [v*math.tau/2048 for v in record['rotation']]
            def transform(p):
                px, py, pz = [v/256 for v in p]
                # Independent scalar Ry -> Rx -> Rz, then layout translation.
                s, c = math.sin(-angles[1]), math.cos(-angles[1])
                px, pz = c*px+s*pz, -s*px+c*pz
                s, c = math.sin(angles[0]), math.cos(angles[0])
                py, pz = c*py-s*pz, s*py+c*pz
                s, c = math.sin(angles[2]), math.cos(angles[2])
                px, py = c*px-s*py, s*px+c*py
                px += record['position'][0]+x*2048
                py += record['position'][1]
                pz += record['position'][2]+z*2048
                return [px*.025, -py*.025, -pz*.025]
            transformed = [transform(points[index]) for index in sorted(used)]
            record['first_plane_points'] = [transform(points[index]) for index in first_indices]
            normal = struct.unpack_from('<iii', model, i32(model,52))
            zero = transform((0,0,0))
            rotated_normal = [v-zv for v,zv in zip(transform(normal),zero)]
            length = sum(v*v for v in rotated_normal)**.5
            record['first_plane_normal'] = [v/length for v in rotated_normal]
            record['expected_bounds'] = [[min(p[i] for p in transformed) for i in range(3)], [max(p[i] for p in transformed) for i in range(3)]]
            record['model_sha256'] = hashlib.sha256(model).hexdigest()
        placements.append(dict(id=mapping['placements'][f'dungeon/{j}'], block=key['id'], name=name, grid=[x,z], sha256=entry['sha256'], records=records))
    names = maps[mapping['region']*4+3]['payload']
    display = names[4+mapping['ordinal']*32:4+(mapping['ordinal']+1)*32].split(b'\0')[0].decode('ascii')
    unsupported = None
    for block_mapping in profile['blocks']:
        if block_mapping['format'] != 'RDB':
            continue
        for record in rdb(by_name[block_mapping['name']]):
            action = record.get('action', {})
            if action.get('kind') in (1, 8) and action['axis'] > 6:
                unsupported = dict(block=block_mapping['id'], name=block_mapping['name'], sha256=by_name[block_mapping['name']]['sha256'], record=block_mapping['records'][str(record['address'])], action=action)
                break
        if unsupported:
            break
    assert unsupported
    return dict(schema='dungeon-independent-observation-v1', location=location, name=display, mapping=mapping, unsupported_axis=unsupported,
                sources={n:hashlib.sha256((root/n).read_bytes()).hexdigest() for n in ['MAPS.BSA','BLOCKS.BSA','ARCH3D.BSA']},
                placements=placements, resource_sources=[dict(file=f'TEXTURE.{a:03d}',format='classic-texture-v1') for a in sorted(textures)])


if __name__ == '__main__':
    root, output = map(pathlib.Path, sys.argv[1:3])
    assert root.is_absolute() and not output.exists()
    output.write_text(json.dumps(pin(root,sys.argv[3]) if len(sys.argv) == 4 else observe(root), indent=2) + '\n')
