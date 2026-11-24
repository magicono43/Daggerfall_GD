"""Independent source observations and explicit, reviewable RMB doorway baseline.

No nearest selection. The named pairs below are checked by their plane extents,
not inferred from source order. Output is separate from accepted increment-1 data.
"""
import sys
sys.dont_write_bytecode = True
import json
import math
import pathlib
import struct
from observe_location_assembly import observe
from observe_layout_source import archive, i32


def pose(position, rotation=0):
    return dict(frame='classic-block-local-v1', position=position,
                position_unit='classic-layout-integer', rotation=[0, rotation, 0],
                rotation_unit='classic-angle-2048', scale=[1, 1, 1])


def observations(root):
    source = observe(root)
    raw_models = (root/'ARCH3D.BSA').read_bytes()
    count, kind = struct.unpack_from('<HH', raw_models)
    assert kind == 0x200
    by_model = {}
    offset = 4
    for n in range(count):
        model_id, size = struct.unpack_from('<II', raw_models, len(raw_models)-count*8+n*8)
        by_model[model_id] = raw_models[offset:offset+size]
        offset += size
    records = {r['id']: r for r in source['records']}
    markers = {m['id']: m for m in source['markers']}
    # Source byte identities, independently observed opposite planes and entry roles.
    pairs = [('home-east', 'building-0000', 'record-00000', 0, 'record-00004', 16, 'record-00033'),
             ('home-north', 'building-0001', 'record-00088', 0, 'record-00089', 4, 'record-00116'),
             ('tavern-front', 'building-0002', 'record-00150', 36, 'record-00200', 2, 'record-00274'),
             ('tavern-rear', 'building-0002', 'record-00150', 46, 'record-00203', 2, 'record-00271')]
    declaration = dict(schema='location-doorways-v1', interiors=[], links=[])
    vectors = []
    for name, building, exterior_id, ep, exit_id, ip, marker_id in pairs:
        parent = next(b['parent'] for b in source['buildings'] if b['id'] == building)
        instance = building+'-interior'
        if not any(i['id'] == instance for i in declaration['interiors']):
            declaration['interiors'].append(dict(id=instance, placement=source['placement'], building=building,
                parent=pose([parent[0], 0, parent[1]], parent[2]), provenance=dict(source=source['name'], policy='explicit-source-door-plane-pair-v1')))
        doors = []
        for record_id, plane_id in [(exterior_id, ep), (exit_id, ip)]:
            r = records[record_id]
            points = next(d['points'] for d in r['doors'] if d['plane'] == plane_id)
            centre = [sum(p[n] for p in points)/len(points) for n in range(3)]
            dimensions = sorted(max(p[n] for p in points)-min(p[n] for p in points) for n in range(3))
            assert all(abs(a-b) < 1e-9 for a, b in zip(dimensions, [0, 1.25, 2.25]))
            b = by_model[r['model']]
            normal = list(struct.unpack_from('<iii', b, i32(b, 52)+12*plane_id))
            normal = [normal[0], -normal[1], -normal[2]]
            length = math.sqrt(sum(v*v for v in normal))
            normal = [v/length for v in normal]
            angle = -r['rotation']*math.tau/2048
            normal = [normal[0]*math.cos(angle)-normal[2]*math.sin(angle), normal[1],
                      normal[0]*math.sin(angle)+normal[2]*math.cos(angle)]
            doors.append(dict(record=record_id, plane=plane_id, centre=centre, normal=normal, points=points))
        m = markers[marker_id]
        forward = doors[1]['normal']
        # Pin the exact block payload and per-record pose/resource. Marker role stays 199/8.
        def endpoint(record_id, plane):
            r = records[record_id]
            return dict(placement=source['placement'], record=record_id, plane=plane,
                        guard=dict(payload_sha256=source['block_sha256'], transform=pose(r['position'], r['rotation']), model_sha256=r['model_sha256']))
        marker_source = [round(m['position'][0]/.025), round(-m['position'][1]/.025), round(-m['position'][2]/.025)]
        declaration['links'].append(dict(id=name, interior=instance, exterior=endpoint(exterior_id, ep),
            exit=endpoint(exit_id, ip), landing=dict(record=marker_id, forward=forward, additional_entry=False,
                guard=dict(payload_sha256=source['block_sha256'], transform=pose(marker_source), texture=dict(archive=199, record=8))),
            outside_offset=doors[0]['normal'], provenance=dict(source=source['name'], source_sha256=source['block_sha256'],
                observation='location_doorway_observation.json', policy='explicit-opposite-plane-and-entry-side-v1')))
        local_ext = [doors[0]['centre'][0]-parent[0]*.025, doors[0]['centre'][1], doors[0]['centre'][2]+(4096-parent[1])*.025]
        delta = [a-b for a,b in zip(local_ext, doors[1]['centre'])]
        if building == 'building-0002':
            assert all(abs(a-b) < 1e-9 for a,b in zip(delta, [0,.05,.15]))
        else:
            assert abs(math.sqrt(sum(v*v for v in delta))-.15) < 1e-9
        assert sum(a*b for a,b in zip(doors[0]['normal'], forward)) < -.999999
        assert sum((a-b)*n for a,b,n in zip(m['position'], doors[1]['centre'], forward)) > 0
        vectors.append(dict(id=name, building=building, instance=instance, doors=doors, marker=m,
                            separation_metres=delta, facing=forward))
    alias_endpoint = endpoint('record-00150',41)
    alias_plane = next(d for d in records['record-00150']['doors'] if d['plane'] == 41)
    alias_centre = [sum(p[n] for p in alias_plane['points'])/len(alias_plane['points']) for n in range(3)]
    assert all(abs(a-b) < 1e-9 for a,b in zip(alias_centre,[69.425,1.175,-41.6]))
    declaration['links'].append(dict(id='tavern-courtyard', exterior=alias_endpoint, entry_alias_of='tavern-rear',
        provenance=dict(source=source['name'], source_sha256=source['block_sha256'],
            policy='explicit-entry-alias-v1', observation='User DFU test 2026-11-24: enter courtyard door #2, arrive at rear interior entrance, immediately exit to outer rear door #3.',
            original_executable_verified=False, geometry_changed=False)))
    return dict(schema='location-doorway-independent-observation-v1', sources=source['sources'],
        block=source['block'], block_sha256=source['block_sha256'], declaration=declaration, vectors=vectors,
        entry_aliases=[dict(id='tavern-courtyard', entry_alias_of='tavern-rear', exterior_centre=alias_centre,
            exterior_plane=41, return_plane=46, exit_record='record-00203', marker='record-00271')], unresolved=[])


if __name__ == '__main__':
    result = observations(pathlib.Path(sys.argv[1]))
    pathlib.Path(sys.argv[2]).write_text(json.dumps(result, indent=2)+'\n')
    print('Verified', len(result['vectors']), 'explicit classic doorway pairs and',len(result['entry_aliases']),'documented entry alias')
