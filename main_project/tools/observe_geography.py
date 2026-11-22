"""Independent READ-only classic geography inventory; no source data is copied."""
import hashlib, json, pathlib, struct, collections

ROOT = pathlib.Path(__file__).resolve().parents[2]
SOURCE = pathlib.Path('C:/Games/Daggerfall/arena2')
def u32(b, p): return struct.unpack_from('<I', b, p)[0]
def sha(b): return hashlib.sha256(b).hexdigest()
def observe():
    files = {n:(SOURCE/n).read_bytes() for n in ['MAPS.BSA','WOODS.WLD','CLIMATE.PAK','POLITIC.PAK']}
    b = files['MAPS.BSA']; count, kind = struct.unpack_from('<HH',b); assert kind == 0x100 and count == 248
    records=[]; pos=4
    for i in range(count):
        size=u32(b,len(b)-count*18+i*18+14)
        records.append((pos,b[pos:pos+size])); pos+=size
    assert pos == len(b)-count*18
    locations=[]; regions=[]
    names_source=(ROOT/'reference_material/daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/API/MapsFile.cs').read_text()
    import re
    region_names=re.findall(r'"([^"]+)"',names_source.split('string[] regionNames = {')[1].split('};')[0])
    for r in range(62):
        pp,p=records[r*4]; tp,t=records[r*4+2]; np,n=records[r*4+3]
        number=u32(n,0) if n else 0
        assert len(n) in (0,4+32*number) and len(t)==17*number
        regions.append({'id':f'region-{r:02d}','ordinal':r,'name':region_names[r],'count':number})
        for i in range(number):
            full,bits,lat,dungeon,key=struct.unpack_from('<IIIBI',t,i*17)
            lon=(bits&0x1ffffff)>>8; latitude=(lat&0xffffff)>>8
            x=lon//128; y=499-latitude//128
            offset=number*4+u32(p,i*4); doors=u32(p,offset)
            qp=offset+4+doors*6+33; quest=struct.unpack_from('<H',p,qp)[0]
            locations.append({'id':f'place-{len(locations):05d}','region':regions[-1]['id'],'ordinal':i,'full_map':full,'map_key':y*1000+x,'quest_id':quest,'name':n[4+i*32:4+(i+1)*32].split(b'\0')[0].decode('ascii'),'pixel':[x,y],'longitude':lon,'latitude':latitude,'type':(bits>>25)&31,'dungeon':dungeon,'discovered':bool(bits&0x40000000),'key':key,'pitem_offset':offset,'quest_address':pp+qp})
    def pak(b):
        output=bytearray()
        for y in range(500):
            p=u32(b,y*4); row=bytearray()
            while len(row)<1001:
                count,value=struct.unpack_from('<HB',b,p); p+=3; assert count and len(row)+count<=1001
                row.extend([value]*count)
            output.extend(row)
        return output
    climate=pak(files['CLIMATE.PAK']); politic=pak(files['POLITIC.PAK'])
    w=files['WOODS.WLD']; header=list(struct.unpack_from('<36I',w)); samples=w[header[7]:header[7]+500000]
    pins=[]
    aligned_edge=next((x,y) for y in range(500) for x in range(1000) if climate[y*1001+x]!=climate[y*1001+x+1])
    for x,y in [(0,0),(999,499),(1,1),(269,407),(500,250),aligned_edge]:
        cell=u32(w,144+(y*1000+x)*4)
        detail=list(w[cell+22:cell+47])
        pins.append({'pixel':[x,y],'coarse':samples[y*1000+x],'climate_raw':climate[y*1001+x],'climate_aligned':climate[y*1001+x+1],'politic_aligned':politic[y*1001+x+1],'cell_offset':cell,'detail':detail,'inner_reversed':[detail[(4-iy)*5+ix] for iy in range(1,4) for ix in range(1,4)]})
    profile={'schema':'classic-geography-profile-v1','files':{n:{'sha256':sha(b),'bytes':len(b)} for n,b in files.items()},'regions':regions,'locations':[{k:v for k,v in x.items() if k in ['id','region','ordinal','full_map','map_key','quest_id']} for x in locations]}
    out=ROOT/'main_project/content/geography';out.mkdir(parents=True,exist_ok=True)
    serialized=json.dumps(profile,separators=(',',':'))+'\n'
    target=out/'profile.json'
    if target.exists() and target.read_text()!=serialized:
        raise RuntimeError('Profile differs: curate an explicit edition mapping; never reallocate existing IDs.')
    target.write_text(serialized)
    report={'schema':'geography-observation-v1','source':str(SOURCE),'files':profile['files'],'regions':len(regions),'locations':len(locations),'woods_header':header,'climate_codes':dict(collections.Counter(climate)),'pins':pins,'location_pins':[locations[i] for i in [0,1,100,1000,len(locations)-1]],'duplicate_full':[(k,v) for k,v in collections.Counter(x['full_map'] for x in locations).items() if v>1],'duplicate_quest':[(k,v) for k,v in collections.Counter((x['region'],x['quest_id']) for x in locations if x['quest_id']).items() if v>1],'forgotten':{str(k):v for k,v in collections.Counter((x['type'],x['discovered']) for x in locations).items()}}
    (ROOT/'main_project/tests/geography_source_observation.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({k:v for k,v in report.items() if k not in ['forgotten']},indent=2))
if __name__=='__main__': observe()


