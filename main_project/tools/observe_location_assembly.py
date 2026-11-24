"""Read-only scalar RMB/ARCH3D observer; no runtime decoder/converter imports.

Explicit ARENA2 and output path. Pins TVRNBS04.RMB at place-00001 and all models.
"""
import sys
sys.dont_write_bytecode = True
import hashlib
import json
import math
import pathlib
import struct
from observe_layout_source import archive, u16, u32, i32


def sha(b):
    return hashlib.sha256(b).hexdigest()


def observe(root):
    project = pathlib.Path(__file__).resolve().parents[1]
    profile_path = project / 'content/layouts/profile.json'
    profile = json.loads(profile_path.read_text())
    _, blocks = archive(root / 'BLOCKS.BSA')
    _, maps = archive(root / 'MAPS.BSA')
    loc = next(m for m in profile['locations'] if m['id'] == 'place-00001')
    mb = maps[loc['region']*4]['payload']
    at = loc['pitem_offset']
    h = at+4+u32(mb, at)*6
    e = h+119+26*u16(mb, h+112)
    assert (mb[e+40], mb[e+41]) == (1, 1)
    assert [mb[e+i] for i in (49, 113, 177)] == [0, 4, 127]
    key = next(b for b in profile['blocks'] if b['name'] == 'TVRNBS04.RMB')
    entry = next(b for b in blocks if b['name'] == key['name'])
    raw = entry['payload']
    models_bytes = (root/'ARCH3D.BSA').read_bytes()
    count, kind = struct.unpack_from('<HH', models_bytes)
    assert kind == 0x200
    models = {}
    offset = 4
    for n in range(count):
        model_id, size = struct.unpack_from('<II', models_bytes, len(models_bytes)-count*8+n*8)
        models.setdefault(model_id,[]).append(models_bytes[offset:offset+size])
        offset += size
    textures = {2}
    records = []
    uv_vectors = {}
    markers = []
    buildings = []

    def model_record(at, context, parent, building, door=False):
        if door:
            position = list(struct.unpack_from('<iii', raw, at))
            rotation = struct.unpack_from('<h', raw, at+12)[0]
            model_id = profile['rmb_door_models'][str(raw[at+16])]
            obj_type = -1
        else:
            model_id = struct.unpack_from('<h', raw, at)[0]*100+raw[at+2]
            obj_type = raw[at+3]
            position = list(struct.unpack_from('<iii', raw, at+36))
            rotation = struct.unpack_from('<h', raw, at+52)[0]
        assert len(models[model_id]) == 1
        data = models[model_id][0]
        points = [struct.unpack_from('<iii', data, i32(data,48)+i*12) for i in range(i32(data,4))]
        planes = []
        cursor = i32(data,60)
        used = set()
        for i in range(i32(data,8)):
            tex = u16(data,cursor+2)
            archive_id = tex >> 7
            textures.add(archive_id)
            indices = []
            for v in range(data[cursor]):
                address = i32(data,cursor+8+v*8)
                if data[:4] == b'v2.5': address *= 3
                assert address % 12 == 0
                indices.append(address//12)
                used.add(address//12)
            if model_id < 905:
                encoded = [list(struct.unpack_from('<hh',data,cursor+12+v*8)) for v in range(min(3,data[cursor]))]
                corrected = [[v-8192*math.floor((v+4096)/8192) if v <= -14336 or v >= 14336 or v == -7168 else v for v in pair] for pair in encoded]
                if corrected != encoded:
                    corrected[1]=[a+b for a,b in zip(corrected[1],corrected[0])]
                    corrected[2]=[a+b for a,b in zip(corrected[2],corrected[1])]
                    vector=dict(plane=i,encoded=encoded,effective=corrected)
                    if vector not in uv_vectors.setdefault(str(model_id),[]): uv_vectors[str(model_id)].append(vector)
            base = archive_id % 100 if archive_id > 100 and archive_id not in (331,156) else archive_id
            if base in (74,56,95) or (archive_id == 331 and (tex&127) > 0):
                planes.append(dict(plane=i,indices=indices,texture=[archive_id,tex&127]))
            cursor += 8+data[cursor]*8
        def rotate(x,z, angle):
            a=angle*math.tau/2048
            return math.cos(a)*x+math.sin(a)*z, -math.sin(a)*x+math.cos(a)*z
        def transform(point):
            x,y,z = (v/256 for v in point)
            x,z = rotate(x,z,-rotation)
            x += position[0]
            z += position[2]
            if context == 'interior' and obj_type == 3:
                y = y-position[1]-max(p[1]/256 for p in points)
            else: y += position[1]
            if context == 'exterior' and parent is not None:
                x,z=rotate(x,z,-parent[2])
                x+=parent[0]
                z+=4096-parent[1]
            if context == "exterior" and parent is None:
                y += 4
                z += 4096
            return [x*.025,-y*.025,-z*.025]
        transformed = [transform(points[i]) for i in sorted(used)]
        for plane in planes: plane['points']=[transform(points[i]) for i in plane.pop('indices')]
        records.append(dict(id=key['records'][str(at)], address=at, context=context, building=building,
                            model=model_id, type='door' if door else 'model', object_type=obj_type,
                            position=position, rotation=rotation, model_sha256=sha(data),
                            bounds=[[min(p[i] for p in transformed) for i in range(3)],
                                    [max(p[i] for p in transformed) for i in range(3)]], doors=planes))

    at=6776
    for i in range(raw[0]):
        start=at
        parent=list(struct.unpack_from('<iii',raw,3+i*20+8))
        building=key['buildings'][str(i)]
        buildings.append(dict(id=building,parent=parent))
        for context in ('exterior','interior'):
            counts=list(raw[at:at+5]); at+=17
            for section,(n,stride) in enumerate(zip(counts,(66,17,16,17,19))):
                for j in range(n):
                    if stride in (66,19): model_record(at,context,parent,building,stride==19)
                    elif stride == 17:
                        tex=u16(raw,at+12)
                        textures.add(tex>>7)
                        if section == 1 and tex>>7 == 199:
                            x,y,z=struct.unpack_from('<iii',raw,at)
                            if context == 'exterior':
                                x+=parent[0];z+=4096-parent[1]
                            role=({4:'rest',8:'entry'}.get(tex&127,'editor-other') if context == 'interior' else 'exterior-arrival' if tex&127 == 8 else 'editor-other')
                            markers.append(dict(id=key['records'][str(at)],building=building,context=context,texture=[199,tex&127],role=role,position=[x*.025,-y*.025,-z*.025]))
                    at+=stride
            assert at <= start+i32(raw,1603+i*4)
        at=start+i32(raw,1603+i*4)
    for i in range(raw[1]): model_record(at,'exterior',None,''); at+=66
    for i in range(raw[2]): textures.add(u16(raw,at+12)>>7); at+=17
    assert at == len(raw)
    sources={name:sha((root/name).read_bytes()) for name in ('BLOCKS.BSA','MAPS.BSA','ARCH3D.BSA','PAL.PAL')}
    sources.update({f'TEXTURE.{t:03d}':sha((root/f'TEXTURE.{t:03d}').read_bytes()) for t in sorted(textures)})
    return dict(schema='location-independent-observation-v1',profile_sha256=sha(profile_path.read_bytes()),
                sources=sources,resource_sources=[dict(file=f'TEXTURE.{t:03d}',format='classic-texture-v1') for t in sorted(textures)],
                uv_vectors=uv_vectors,markers=markers,location=loc['id'],placement=loc['placements']['exterior/0'],block=key['id'],name=key['name'],block_sha256=sha(raw),buildings=buildings,
                ground=dict(side_metres=102.4,tile_metres=6.4,height_metres=-.025,tiles_sha256=sha(raw[1739:1995]),tiles=list(raw[1739:1995])),records=records)


if __name__ == '__main__':
    result=observe(pathlib.Path(sys.argv[1]))
    pathlib.Path(sys.argv[2]).write_text(json.dumps(result,indent=2)+'\n')
    print(len(result['records']), 'model/action-door vectors;',len(result['sources']),'source hashes')
