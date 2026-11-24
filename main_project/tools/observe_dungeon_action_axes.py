"""Independent, read-only inventory of classic motion actions outside axes 0..6.

Uses scalar source offsets, never production decoder output. Existing outputs
are refused; original parameters and model tags remain evidence, not execution.
"""
import hashlib
import json
import pathlib
import struct
import sys

sys.dont_write_bytecode = True
from observe_layout_source import archive, u16, u32, i32


def observe(root):
    source, entries = archive(root / 'BLOCKS.BSA')
    records = []
    blocks = []
    for entry in entries:
        if not entry['name'].endswith('.RDB'):
            continue
        b = entry['payload']
        seen = set()
        count = 0
        for group in range(u32(b, 4) * u32(b, 8)):
            address = i32(b, 9532 + group * 4)
            while address >= 0:
                assert address not in seen
                seen.add(address)
                count += 1
                resource = u32(b, address + 21)
                if b[address + 20] == 1:
                    model_index = u16(b, resource + 12)
                    model = b[20 + model_index * 8:28 + model_index * 8]
                    action_at = i32(b, resource + 19)
                    if action_at > 0:
                        axis, duration, magnitude, target, kind = struct.unpack_from('<BHH i B', b, action_at)
                        if kind in [1, 8] and axis > 6:
                            records.append(dict(name=entry['name'], sha256=entry['sha256'],
                                                address=address, action_offset=action_at,
                                                model_id=int(model[:5]), description=model[5:].decode('ascii').rstrip('\0'),
                                                raw=dict(kind=kind, axis=axis, duration=duration,
                                                         magnitude=magnitude, target_address=target)))
                address = i32(b, address)
        blocks.append(dict(name=entry['name'], sha256=entry['sha256'], records=count))
    assert hashlib.sha256((root / 'BLOCKS.BSA').read_bytes()).hexdigest() == hashlib.sha256(source).hexdigest()
    return dict(schema='classic-action-axes-observation-v1', source_sha256=hashlib.sha256(source).hexdigest(),
                blocks=blocks, records=records, gameplay_ready=False)


if __name__ == '__main__':
    root, output = map(pathlib.Path, sys.argv[1:])
    assert root.is_absolute() and output.is_absolute() and not output.exists()
    result = observe(root)
    output.write_text(json.dumps(result, indent=2) + '\n')
    print('RDB blocks:', len(result['blocks']), 'exceptional motion axes:', len(result['records']))
