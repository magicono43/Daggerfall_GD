"""Independent READ-only observations; no runtime importer or identity allocation.

Usage: python tools/observe_layout_source.py EXPLICIT_ARENA2 NEW_OUTPUT
"""
import hashlib
import json
import pathlib
import struct
import sys


def u16(b, p):
    return struct.unpack_from('<H', b, p)[0]


def u32(b, p):
    return struct.unpack_from('<I', b, p)[0]


def i32(b, p):
    return struct.unpack_from('<i', b, p)[0]


def archive(path):
    b = path.read_bytes()
    count, kind = struct.unpack_from('<HH', b)
    assert kind == 0x100
    directory = len(b) - count * 18
    entries = []
    offset = 4
    for i in range(count):
        at = directory + 18 * i
        name = b[at:at + 14].split(b'\0')[0].decode('ascii')
        size = u32(b, at + 14)
        assert offset + size <= directory
        payload = b[offset:offset + size]
        entries.append(dict(name=name, ordinal=i, offset=offset, size=size,
                            sha256=hashlib.sha256(payload).hexdigest(), payload=payload))
        offset += size
    assert offset == directory
    return b, entries


def texture_observation(path):
    """Independent indexed pixels; no import of the production decoder."""
    b = path.read_bytes()
    records = []
    for record in range(struct.unpack_from('<h', b)[0]):
        start = i32(b, 28 + record * 20)
        x, y, width, height, compression, length, data, normal, frames, unknown, sx, sy = struct.unpack_from('<hhhhHIIhHhhh', b, start)
        assert compression in (0, 0x900) and width > 0 and height > 0 and frames > 0
        table = start + data
        pins = []
        for frame in range(frames):
            extent = None
            if frames == 1:
                pixels = b''.join(b[table + row * 256:table + row * 256 + width] for row in range(height))
            else:
                at = table + i32(b, table + frame * 4)
                begin = at
                cx, cy = struct.unpack_from('<hh', b, at)
                assert (cx, cy) == (width, height)
                at += 4
                pixels = bytearray()
                for row in range(cy):
                    written = 0
                    while written < cx:
                        transparent, literal = b[at:at + 2]
                        at += 2
                        assert transparent + literal > 0 and written + transparent + literal <= cx
                        pixels.extend(b'\0' * transparent)
                        pixels.extend(b[at:at + literal])
                        at += literal
                        written += transparent + literal
                assert at <= start + length
                extent = [begin, at]
            assert len(pixels) == width * height
            pins.append(dict(frame=frame, sha256=hashlib.sha256(pixels).hexdigest(), extent=extent,
                             first_pixels=list(pixels[:12]), last_pixels=list(pixels[-12:])))
        records.append(dict(record=record, source_position=start, width=width, height=height,
                            compression=compression, frames=frames, offset=[x, y], scale=[sx, sy],
                            normal=normal, unknown=unknown, logical_size=length, data_offset=data, pins=pins))
    return dict(profile='classic-texture-transparent-runs-v1', sha256=hashlib.sha256(b).hexdigest(),
                record_count=len(records), frame_count=sum(r['frames'] for r in records), records=records)


def observe(root):
    block_bytes, blocks = archive(root / 'BLOCKS.BSA')
    map_bytes, maps = archive(root / 'MAPS.BSA')
    rmb = next(e for e in blocks if e['name'].endswith('.RMB'))
    b = rmb['payload']
    count, misc_models, misc_flats = b[:3]
    positions = [list(struct.unpack_from('<IIiii', b, 3 + i * 20)) for i in range(count)]
    sizes = [i32(b, 1603 + i * 4) for i in range(32)]
    scopes = []
    at = 6776
    for i in range(count):
        start = at
        for context in ('exterior', 'interior'):
            counts = list(b[at:at + 5])
            scopes.append(dict(building=i, context=context, address=at, counts=counts))
            at += 17 + sum(c * stride for c, stride in zip(counts, (66, 17, 16, 17, 19)))
        assert at <= start + sizes[i]
        at = start + sizes[i]
    at += misc_models * 66 + misc_flats * 17
    assert at == len(b)
    rdb = next(e for e in blocks if e['name'] == 'B0000000.RDB')
    db = rdb['payload']
    width, height, root_at = struct.unpack_from('<III', db, 4)
    assert root_at == 9532
    roots = [i32(db, root_at + i * 4) for i in range(width * height)]
    objects = []
    for root_index, address in enumerate(roots):
        seen = set()
        while address >= 0:
            assert address not in seen
            seen.add(address)
            nxt, previous, x, y, z, kind, resource = struct.unpack_from('<iiiiiBI', db, address)
            objects.append(dict(root=root_index, address=address, next=nxt, previous=previous,
                                position=[x, y, z], kind=kind, resource=resource))
            address = nxt
    # Independent containing-location source headers, preserving accepted identities.
    geography = json.loads((pathlib.Path(__file__).resolve().parents[1] / 'content/geography/profile.json').read_text())
    regions = {r['id']: r for r in geography['regions']}
    locations = []
    for m in geography['locations'][:3]:
        region = regions[m['region']]
        b = maps[region['ordinal'] * 4]['payload']
        at = region['count'] * 4 + u32(b, m['ordinal'] * 4)
        doors = u32(b, at)
        header = at + 4 + doors * 6
        building_count = u16(b, header + 112)
        exterior = header + 119 + building_count * 26
        locations.append(dict(id=m['id'], region=region['ordinal'], ordinal=m['ordinal'],
                              pitem_offset=at, location_id=u16(b, header + 33),
                              door_count=doors, building_count=building_count,
                              width=b[exterior + 40], height=b[exterior + 41],
                              first_block_codes=[b[exterior + j] for j in (49, 113, 177)]))
    clean = lambda e: {k: v for k, v in e.items() if k != 'payload'}
    interior = next(e for e in blocks if e['name'] == 'MANRAS02.RMB')
    ib = interior['payload']
    ec = list(ib[6776:6781])
    inside_at = 6793 + sum(c * stride for c, stride in zip(ec, (66, 17, 16, 17, 19)))
    ic = list(ib[inside_at:inside_at + 5])
    assert ic[0] > 0
    model_at = inside_at + 17
    interior_pin = dict(**clean(interior), address=inside_at, counts=ic,
                        first_model_id=struct.unpack_from('<h', ib, model_at)[0] * 100 + ib[model_at + 2],
                        first_model_position=list(struct.unpack_from('<iii', ib, model_at + 36)),
                        first_model_y_rotation=struct.unpack_from('<h', ib, model_at + 52)[0])
    archives = set()
    for scope in scopes:
        at = scope['address'] + 17 + scope['counts'][0] * 66
        for i in range(scope['counts'][1]):
            archives.add(u16(rmb['payload'], at + i * 17 + 12) >> 7)
    resource_sources = [dict(file=f'TEXTURE.{a:03d}', format='classic-texture-v1') for a in sorted(archives)]
    resource_hashes = {s['file']: hashlib.sha256((root / s['file']).read_bytes()).hexdigest()
                       for s in resource_sources}
    return dict(schema='layout-independent-observation-v1', resource_sources=resource_sources,
                resource_hashes=resource_hashes,
                texture210=texture_observation(root / 'TEXTURE.210'),
                sources={name: dict(size=len(b), sha256=hashlib.sha256(b).hexdigest())
                         for name, b in [('BLOCKS.BSA', block_bytes), ('MAPS.BSA', map_bytes)]},
                block_inventory=[clean(e) for e in blocks], maps_inventory=[clean(e) for e in maps],
                rmb_pin=dict(**clean(rmb), buildings=count, misc_models=misc_models,
                             misc_flats=misc_flats, positions=positions, scopes=scopes),
                interior_pin=interior_pin,
                rdb_pin=dict(**clean(rdb), width=width, height=height, roots=roots, objects=objects),
                locations=locations)


if __name__ == '__main__':
    root, output = map(pathlib.Path, sys.argv[1:])
    assert root.is_absolute() and not output.exists(), 'Explicit root and NEW output required'
    output.write_text(json.dumps(observe(root), indent=2) + '\n', encoding='utf-8')
