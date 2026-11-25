"""Read-only source review for the explicit MOVE-007 ramp list.

No runtime imports, automatic exception publication, or writes to classic data.
Usage: python tools/observe_steep_ramp_list.py EXPLICIT_ARENA2 NEW_JSON [NEW_PNG]
The three selected source models/faces are reviewed corridor topology, not a
general classifier. The complete upward-facing steep-plane inventory is retained
so the selection can be checked against ordinary steep surfaces.
"""
import collections
import hashlib
import json
import math
import pathlib
import struct
import sys

sys.dont_write_bytecode = True
from observe_dungeon_assembly import rdb
from observe_layout_source import archive


SELECTED = {61030: 1, 67027: 6, 67029: 6}


def digest(data):
    return hashlib.sha256(data).hexdigest()


def dot(a, b):
    return sum(x*y for x, y in zip(a, b))


def subtract(a, b):
    return [x-y for x, y in zip(a, b)]


def cross(a, b):
    return [a[1]*b[2]-a[2]*b[1], a[2]*b[0]-a[0]*b[2], a[0]*b[1]-a[1]*b[0]]


def rotate(v, rotation):
    x, y, z = v
    ax, ay, az = [a*math.tau/2048 for a in rotation]
    s, c = math.sin(-ay), math.cos(-ay)
    x, z = c*x+s*z, -s*x+c*z
    s, c = math.sin(ax), math.cos(ax)
    y, z = c*y-s*z, s*y+c*z
    s, c = math.sin(az), math.cos(az)
    return [c*x-s*y, s*x+c*y, z]


def decode_model(data):
    point_at, normal_at, face_at = [struct.unpack_from('<i', data, p)[0] for p in (48, 52, 60)]
    faces = []
    for plane in range(struct.unpack_from('<i', data, 8)[0]):
        count = data[face_at]
        indices = []
        for vertex in range(count):
            offset = struct.unpack_from('<i', data, face_at+8+vertex*8)[0]
            if data[:4] == b'v2.5':
                offset *= 3
            assert offset % 12 == 0
            indices.append(offset//12)
        points = [[v/256*.025 for v in struct.unpack_from('<iii', data, point_at+i*12)] for i in indices]
        normal = list(struct.unpack_from('<iii', data, normal_at+plane*12))
        faces.append(dict(plane=plane, points_source_metres=points, normal_source=normal))
        face_at += 8+count*8
    return dict(sha256=digest(data), faces=faces)


def angle(normal):
    length = math.sqrt(dot(normal, normal))
    return math.degrees(math.acos(max(-1, min(1, -normal[1]/length)))) if length else 180


def observe(root):
    project = pathlib.Path(__file__).resolve().parents[1]
    profile_bytes = (project/'content/layouts/profile.json').read_bytes()
    profile = json.loads(profile_bytes)
    block_keys = {b['name']: b for b in profile['blocks'] if b['format'] == 'RDB'}
    block_bytes, blocks = archive(root/'BLOCKS.BSA')
    raw = (root/'ARCH3D.BSA').read_bytes()
    count, kind = struct.unpack_from('<HH', raw)
    assert kind == 0x200
    models, offset = {}, 4
    for n in range(count):
        key, size = struct.unpack_from('<II', raw, len(raw)-count*8+n*8)
        models.setdefault(key, []).append(raw[offset:offset+size])
        offset += size
    assert offset == len(raw)-count*8
    decoded, inventory, selected, totals = {}, [], [], collections.Counter()
    duplicate_ids = {}
    for block in blocks:
        if not block['name'].endswith('.RDB'):
            continue
        mapping = block_keys[block['name']]
        assert mapping['sha256'] == block['sha256']
        totals['rdb_blocks'] += 1
        if block['name'].startswith('B'):
            totals['border_blocks'] += 1
        for record in rdb(block):
            if 'model' not in record:
                continue
            totals['model_occurrences'] += 1
            key = record['model']
            if key not in decoded:
                decoded[key] = decode_model(models[key][0])
                if len(models[key]) > 1:
                    duplicate_ids[key] = [decode_model(data) for data in models[key]]
            model = decoded[key]
            steep = []
            for variant in duplicate_ids.get(key, [model]):
                for face in variant['faces']:
                    degrees = angle(rotate(face['normal_source'], record['rotation']))
                    if 45.000001 < degrees < 89.999999:
                        steep.append(dict(plane=face['plane'], degrees=round(degrees, 6), model_sha256=variant['sha256']))
            identity = dict(block=mapping['id'], block_name=block['name'], block_sha256=block['sha256'],
                            record=mapping['records'][str(record['address'])], source_address=record['address'],
                            model=key, model_sha256=model['sha256'], position_source=record['position'],
                            rotation_source=record['rotation'], description=record['description'])
            if steep:
                inventory.append(dict(**identity, steep_planes=steep))
                totals['steep_occurrences'] += 1
                totals['steep_planes'] += len(steep)
            if key in SELECTED:
                # No moving/rotated-over/inverted variants silently inherit this list.
                assert len(models[key]) == 1
                assert 'action' not in record
                assert record['rotation'][0] == record['rotation'][2] == 0
                selected.append(dict(**identity, floor_plane=SELECTED[key]))

    candidates = []
    for key, plane in sorted(SELECTED.items()):
        model = decoded[key]
        face = model['faces'][plane]
        points = face['points_source_metres']
        assert len(points) == 4
        geometric = cross(subtract(points[1], points[0]), subtract(points[2], points[0]))
        # Winding can oppose the stored normal; compare unsigned parallelism.
        agreement = abs(dot(geometric, face['normal_source']))/math.sqrt(dot(geometric, geometric)*dot(face['normal_source'], face['normal_source']))
        assert agreement > .99999
        width = max(p[0] for p in points)-min(p[0] for p in points)
        rise = max(p[1] for p in points)-min(p[1] for p in points)
        run = max(p[2] for p in points)-min(p[2] for p in points)
        assert abs(width-3.2) < .00001
        assert abs(math.degrees(math.atan2(rise, run))-angle(face['normal_source'])) < .2
        candidates.append(dict(model=key, model_sha256=model['sha256'], floor_plane=plane,
                               geometric_angle_degrees=round(math.degrees(math.atan2(rise, run)), 6),
                               stored_normal_angle_degrees=round(angle(face['normal_source']), 6),
                               width_metres=width, rise_metres=rise, horizontal_run_metres=run,
                               floor_length_metres=math.hypot(rise, run),
                               source_occurrences=sum(v['model'] == key for v in selected),
                               border_occurrences=sum(v['model'] == key and v['block_name'].startswith('B') for v in selected),
                               geometry=model['faces']))
    totals['unique_models'] = len(decoded)
    totals['selected_source_occurrences'] = len(selected)
    totals['selected_border_occurrences'] = sum(v['block_name'].startswith('B') for v in selected)
    totals['selected_blocks'] = len({v['block'] for v in selected})
    # Explicit neighbouring asset observed during the physical placement review.
    # This is source measurement, not an automatic stair/exception classifier.
    stair = decoded[67025]
    risers = [face for face in stair['faces'] if face['normal_source'] == [0, 0, -256]]
    riser_heights = [round(max(p[1] for p in face['points_source_metres'])-min(p[1] for p in face['points_source_metres']), 6) for face in risers]
    assert len(risers) == 16 and set(riser_heights) == {0.3}
    # Avoid repeating model-plane observations and hashes for every occurrence.
    groups = {}
    for item in inventory:
        group_key = (item['model'], tuple(item['rotation_source']))
        if group_key not in groups:
            variants = collections.defaultdict(list)
            for plane in item['steep_planes']:
                variants[plane['model_sha256']].append(dict(plane=plane['plane'], degrees=plane['degrees']))
            groups[group_key] = dict(model=item['model'], rotation_source=item['rotation_source'],
                                     variants=[dict(model_sha256=sha, steep_planes=planes) for sha, planes in variants.items()],
                                     occurrences=[])
        groups[group_key]['occurrences'].append(dict(block=item['block'], record=item['record'], source_address=item['source_address']))
    return dict(schema='reviewed-steep-ramp-source-list-v1',
                status='source observations only; runtime implementation and qualification are recorded separately',
                sources={'BLOCKS.BSA': digest(block_bytes), 'ARCH3D.BSA': digest(raw), 'layouts/profile.json': digest(profile_bytes)},
                coverage=dict(totals), candidates=candidates, source_occurrences=selected,
                related_ordinary_stair_model=dict(model=67025, model_sha256=stair['sha256'], vertical_riser_count=len(risers), vertical_riser_heights_metres=riser_heights,
                                                 policy='Not included in the three-floor exception list; ordinary step and collision rules remain authoritative.'),
                duplicate_model_ids={key: [v['sha256'] for v in variants] for key, variants in duplicate_ids.items()},
                complete_steep_plane_inventory=list(groups.values()),
                limits=['Slope inventory uses placed source normals, not route semantics; all variants of duplicate model IDs are inventoried without selecting runtime semantics.',
                        'Three source corridor floor faces selected by explicit geometry review, not angle classification.',
                        'Source block records are templates; this report does not certify every assembled location or alternate/replaced geometry.',
                        'No Godot collision, body clearance, speed, override precedence or runtime exception checks are claimed by this source-only tool.'])


def diagram(report, output):
    """Source-mesh elevation plot; Pillow is only an optional reporting tool."""
    from PIL import Image, ImageDraw, ImageFont
    image = Image.new('RGB', (1200, 540), '#f5f6f8')
    draw = ImageDraw.Draw(image)
    title_font = ImageFont.truetype('C:/Windows/Fonts/arial.ttf', 25)
    font = ImageFont.truetype('C:/Windows/Fonts/arial.ttf', 18)
    small = ImageFont.truetype('C:/Windows/Fonts/arial.ttf', 15)
    draw.text((25, 18), 'Three steep corridor floors — proposed source list', fill='#172532', font=title_font)
    draw.text((25, 53), 'Side elevations in metres. Side walls removed from view; collision and clearance remain to be tested.', fill='#435565', font=small)
    for ordinal, candidate in enumerate(report['candidates']):
        left = 25+ordinal*395
        faces = candidate['geometry']
        points = [p for face in faces for p in face['points_source_metres']]
        zmin, zmax = min(p[2] for p in points), max(p[2] for p in points)
        ymin, ymax = min(-p[1] for p in points), max(-p[1] for p in points)
        scale = min(310/(ymax-ymin), 320/(zmax-zmin))
        def project(point):
            return (left+25+(point[2]-zmin)*scale, 425-(-point[1]-ymin)*scale)
        draw.text((left, 95), 'Model %d · floor face %d' % (candidate['model'], candidate['floor_plane']), fill='#172532', font=font)
        for face in faces:
            route = [project(p) for p in face['points_source_metres']]
            draw.line(route+[route[0]], fill='#a5b2bf', width=2)
        floor = faces[candidate['floor_plane']]
        route = [project(p) for p in floor['points_source_metres']]
        draw.line(route+[route[0]], fill='#c66009', width=6)
        draw.text((left, 444), '%.2f° · %.1f m rise · %.1f m run' % (candidate['geometric_angle_degrees'], candidate['rise_metres'], candidate['horizontal_run_metres']), fill='#172532', font=small)
        draw.text((left, 469), '3.2 m wide · %d exact source records' % candidate['source_occurrences'], fill='#435565', font=small)
    draw.text((25, 512), 'Orange: selected floor only. Grey: remaining mesh edges. No other steep faces inherit an exception.', fill='#435565', font=small)
    image.save(output)


if __name__ == '__main__':
    root, output = map(pathlib.Path, sys.argv[1:3])
    assert root.is_absolute() and not output.exists()
    if len(sys.argv) > 3:
        assert not pathlib.Path(sys.argv[3]).exists()
    report = observe(root)
    output.write_text(json.dumps(report, indent=2)+'\n')
    if len(sys.argv) > 3:
        diagram(report, pathlib.Path(sys.argv[3]))
