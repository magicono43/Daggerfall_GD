"""Read-only independent marker inventory. Uses source bytes, not LOC projections.

The flat payload has no orientation. Never promotes a zero rotation to evidence
of original-game facing. Refuses existing output and preserves source hashes.
"""
import hashlib
import json
import pathlib
import struct
import sys
import math

sys.dont_write_bytecode = True
from observe_layout_source import archive, u16, u32, i32


def observe(root):
    project = pathlib.Path(__file__).resolve().parents[1]
    profile_path = project / 'content/layouts/profile.json'
    profile = json.loads(profile_path.read_text())
    files = {name: hashlib.sha256((root/name).read_bytes()).hexdigest()
             for name in ['MAPS.BSA', 'BLOCKS.BSA', 'ARCH3D.BSA']}
    assert all(files[name] == profile['files'][name] for name in ['MAPS.BSA', 'BLOCKS.BSA'])
    _, maps = archive(root/'MAPS.BSA')
    _, blocks = archive(root/'BLOCKS.BSA')
    block_bytes = {entry['name']: entry for entry in blocks}
    keys = {entry['name']: entry for entry in profile['blocks']}
    result = {}
    for location in ['place-00032', 'place-04310']:
        mapping = next(item for item in profile['locations'] if item['id'] == location)
        names = maps[mapping['region']*4+3]['payload']
        name = names[4+mapping['ordinal']*32:4+(mapping['ordinal']+1)*32].split(b'\0')[0].decode('ascii')
        data = maps[mapping['region']*4+1]['payload']
        count = u32(data, 0)
        matches = [struct.unpack_from('<IHH', data, 4+n*8) for n in range(count)
                   if u16(data, 10+n*8) == mapping['location_id']]
        assert len(matches) == 1
        at = 4+count*8+matches[0][0]
        at += 4+u32(data, at)*6+112
        placements = []
        unique = set()
        for index in range(u16(data, at+10)):
            x, z, bits = struct.unpack_from('<bbH', data, at+17+index*4)
            block_name = f'{"NWLSBM"[bits >> 11]}{bits & 1023:07d}.RDB'
            entry, key = block_bytes[block_name], keys[block_name]
            b = entry['payload']
            width, height = struct.unpack_from('<II', b, 4)
            markers = []
            seen = set()
            for group in range(width*height):
                address = i32(b, 9532+group*4)
                while address >= 0:
                    assert address not in seen
                    seen.add(address)
                    nxt, previous, px, py, pz, kind, resource = struct.unpack_from('<iiiiiBI', b, address)
                    if kind == 3:
                        texture, flags, magnitude, sound, target, action = struct.unpack_from('<HHBBiB', b, resource)
                        archive_id, record = texture >> 7, texture & 127
                        if archive_id == 199:
                            marker_id = key['records'].get(str(address))
                            # Unsupported blocks have no allocated runtime record IDs.
                            # Source addresses remain evidence, never invented IDs.
                            source_key = marker_id or f'source-address:{address}'
                            identity = (mapping['placements'][f'dungeon/{index}'], source_key)
                            assert identity not in unique
                            unique.add(identity)
                            markers.append(dict(id=marker_id, address=address, archive=archive_id,
                                                record=record, local_position=[px, py, pz],
                                                anchor_metres=[(px+x*2048)*.025, -py*.025, -(pz+z*2048)*.025],
                                                flags=flags, magnitude=magnitude, sound=sound,
                                                target=target, action=action,
                                                orientation_encoded=False))
                    address = nxt
            placements.append(dict(id=mapping['placements'][f'dungeon/{index}'], block=key['id'],
                                   name=block_name, grid=[x, z], starting=bool(bits & 1024),
                                   sha256=entry['sha256'], qualification=key['qualification'],
                                   diagnostic=key.get('diagnostic'),
                                   markers=sorted(markers, key=lambda m: m['address'])))
        result[location] = dict(name=name, mapping=mapping, placements=placements,
                                unique_editor_markers=len(unique),
                                original_opening_role_verified=False,
                                original_facing_verified=False)
    assert files == {name: hashlib.sha256((root/name).read_bytes()).hexdigest() for name in files}
    return dict(schema='dungeon-marker-source-observation-v1', sources=files,
                profile_sha256=hashlib.sha256(profile_path.read_bytes()).hexdigest(),
                frame='dungeon-geometry-metres-v1', locations=result)


def unknown_actions(root):
    # Independent frozen classification: existing understood structural kinds.
    known = {0,1,2,3,4,5,6,7,8,9,11,12,14,16,17,18,20,21,22,23,24,25,26,28,29,30,31,99}
    profile_path = pathlib.Path(__file__).resolve().parents[1]/'content/layouts/profile.json'
    profile = json.loads(profile_path.read_text())
    source, entries = archive(root/'BLOCKS.BSA')
    assert hashlib.sha256(source).hexdigest() == profile['files']['BLOCKS.BSA']
    records = []
    for key, entry in zip(profile['blocks'], entries):
        assert key['name'] == entry['name'] and key['sha256'] == entry['sha256']
        if key['format'] != 'RDB':
            continue
        b = entry['payload']
        width, height = struct.unpack_from('<II', b, 4)
        seen = set()
        for group in range(width*height):
            address = i32(b, 9532+group*4)
            while address >= 0:
                assert address not in seen
                seen.add(address)
                nxt, previous, x, y, z, kind, resource = struct.unpack_from('<iiiiiBI', b, address)
                raw = None
                if kind == 3:
                    texture, flags, magnitude, sound, target, action = struct.unpack_from('<HHBBiB', b, resource)
                    raw = dict(kind=action, target_address=target)
                elif kind == 1:
                    action_at = i32(b, resource+19)
                    if action_at > 0:
                        axis, duration, magnitude, target, action = struct.unpack_from('<BHH i B', b, action_at)
                        raw = dict(kind=action, target_address=target, axis=axis, duration=duration, magnitude=magnitude)
                if raw and raw['kind'] not in known:
                    records.append(dict(block=key['id'], name=key['name'], sha256=key['sha256'],
                                        address=address, record=key['records'].get(str(address)),
                                        qualification=key['qualification'], type='flat' if kind == 3 else 'model', raw=raw))
                address = nxt
    counts = {}
    for record in records:
        code = str(record['raw']['kind'])
        counts[code] = counts.get(code, 0)+1
    return dict(schema='classic-unknown-actions-observation-v1', source_sha256=hashlib.sha256(source).hexdigest(),
                profile_sha256=hashlib.sha256(profile_path.read_bytes()).hexdigest(), counts=counts,
                records=sorted(records, key=lambda r: (r['block'], r['address'])),
                policy='classic-unknown-action-metadata-v1', execution_verified=False)


def opening_floor(root):
    # Independently inspect the original cave model under the Enter anchor.
    # Numeric ARCH3D directory and scalar pose math; no production decoder.
    source = (root/'ARCH3D.BSA').read_bytes()
    count, kind = struct.unpack_from('<HH', source)
    assert kind == 0x200
    offset = 4
    matches = []
    for index in range(count):
        identity, size = struct.unpack_from('<II', source, len(source)-count*8+index*8)
        if identity == 60200:
            matches.append(source[offset:offset+size])
        offset += size
    assert len(matches) == 1
    b = matches[0]
    assert hashlib.sha256(b).hexdigest() == '192f449e46e373ff5b9d4cdf6f7ad982b80d2191d0fa9f0eb4b3519439a3ea25'
    points = []
    angle = -(-4096)*math.tau/2048
    for index in range(i32(b, 4)):
        x,y,z = struct.unpack_from('<iii', b, i32(b,48)+index*12)
        x,y,z = x/256,y/256,z/256
        x,z = math.cos(angle)*x+math.sin(angle)*z,-math.sin(angle)*x+math.cos(angle)*z
        points.append([(x+512)*.025,-y*.025,-(z+1280)*.025])
    at = i32(b,60)
    hits = []
    for plane in range(i32(b,8)):
        n = b[at]
        indices = []
        for corner in range(n):
            address = i32(b,at+8+corner*8)
            if b[:4] == b'v2.5': address *= 3
            assert address % 12 == 0
            indices.append(address//12)
        for triangle in range(1,n-1):
            a,c,d = [points[i] for i in [indices[0],indices[triangle],indices[triangle+1]]]
            determinant = (c[2]-d[2])*(a[0]-d[0])+(d[0]-c[0])*(a[2]-d[2])
            if abs(determinant) < 1e-10: continue
            u = ((c[2]-d[2])*(12.75-d[0])+(d[0]-c[0])*(-41.8-d[2]))/determinant
            v = ((d[2]-a[2])*(12.75-d[0])+(a[0]-d[0])*(-41.8-d[2]))/determinant
            w = 1-u-v
            height = u*a[1]+v*c[1]+w*d[1]
            if min(u,v,w) >= -1e-8 and -1.375 <= height <= .625:
                hits.append(dict(plane=plane,triangle=triangle-1,height=height,vertices=[a,c,d]))
        at += 8+n*8
    assert hits
    return dict(schema='opening-source-floor-observation-v1', location='place-04310',
                placement='placement-00001', record='record-00286', model=60200,
                source_sha256=hashlib.sha256(source).hexdigest(), model_sha256=hashlib.sha256(b).hexdigest(),
                anchor=[12.75,.625,-41.8], nearest_floor=max(h['height'] for h in hits),
                hits=hits, actor_clearance_verified=False)


if __name__ == '__main__':
    root, output = map(pathlib.Path, sys.argv[1:3])
    assert root.is_absolute() and output.is_absolute() and not output.exists()
    assert len(sys.argv) == 3 or sys.argv[3:] in [['--unknown-actions'],['--opening-floor']]
    result = observe(root) if len(sys.argv) == 3 else (unknown_actions(root) if sys.argv[3] == '--unknown-actions' else opening_floor(root))
    output.write_text(json.dumps(result, indent=2)+'\n')
