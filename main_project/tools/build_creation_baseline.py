"""Rebuild authored creation policy from approved tables and pinned MIT metadata.

Does not copy original game text, images, sounds or CLASS files. Runtime DATA
reads those from the selected external installation.
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / 'reference_material/daggerfall-unity-1.1.1-cve-2025/Assets/Scripts'
OUT = ROOT / 'main_project/content/char/career.json'
attributes = 'strength intelligence willpower agility endurance personality speed luck'.split()
skills = 'medical etiquette streetwise jumping orcish harpy giantish dragonish nymph daedric spriggan centaurian impish lockpicking mercantile pickpocket stealth swimming climbing backstabbing dodging running destruction restoration illusion alteration thaumaturgy mysticism short_blade long_blade hand_to_hand axe blunt_weapon archery critical_strike'.split()
skills = [skill.replace('_','-') for skill in skills]
traits = {}
def add(category, targets, costs, side='advantage', conflict='', singleton=False):
    for target, cost in zip(targets.split(), costs):
        ident = category if target == 'none' else category + '/' + target
        traits[ident] = dict(label=(category.replace('_',' ').title() + (': ' + target.replace('_',' ').title() if target != 'none' else '')), category=category, target=target, cost=cost, side=side, conflict=conflict, singleton=singleton)
for cat,cost in [('acute_hearing',1),('adrenaline_rush',4),('athleticism',4)]: add(cat,'none',[cost])
add('bonus_to_hit','animals daedra humanoid undead',[6,3,6,6],conflict='enemy')
weapons='axe blunt hand_to_hand long_blade missile short_blade'
effects='disease fire frost magic paralysis poison shock'
add('expertise',weapons,[2]*6,conflict='weapon')
add('immunity',effects,[10]*7,conflict='tolerance')
add('increased_magery','1 1.5 1.75 2 3',[2,4,6,8,10],singleton=True)
add('rapid_healing','general darkness light',[4,3,2])
add('regenerate_health','general darkness light immersed',[14,10,6,2])
add('resistance',effects,[5]*7,conflict='tolerance')
add('spell_absorption','general darkness light',[14,12,8])
add('critical_weakness',effects,[-14]*7,'disadvantage','tolerance')
add('damage','holy_places sunlight',[-6,-10],'disadvantage')
add('darkness_powered_magery','lower_daylight unable_daylight',[-7,-10],'disadvantage',singleton=True)
add('forbidden_armor','chain leather plate',[-2,-1,-5],'disadvantage')
add('forbidden_material','adamantium daedric dwarven ebony elven iron mithril orcish silver steel',[-5,-2,-7,-5,-9,-1,-6,-3,-6,-10],'disadvantage')
add('forbidden_shield','buckler kite round tower',[-1]*4,'disadvantage')
add('forbidden_weaponry',weapons,[-2]*6,'disadvantage','weapon')
add('no_spell_point_regeneration','none',[-14],'disadvantage')
add('light_powered_magery','lower_darkness unable_darkness',[-10,-14],'disadvantage',singleton=True)
add('low_tolerance',effects,[-5]*7,'disadvantage','tolerance')
add('phobia','animals daedra humanoid undead',[-4]*4,'disadvantage','enemy')
race_src=(SRC/'Game/Entities/RaceTemplate.cs').read_text()
race_ids=['breton','redguard','nord','dark-elf','high-elf','wood-elf','khajiit','argonian']
benefits=[
 'Magic resistance flag. Resistance resolution and class stacking remain owner-defined.',
 'With a non-archery weapon: hit and damage modifiers each floor(level / 3). Excludes unarmed attacks.',
 'Frost resistance flag. Resistance resolution and class stacking remain owner-defined.',
 'With a weapon: hit and damage modifiers each floor(level / 4). Excludes unarmed attacks.',
 'Paralysis immunity flag. Interactions with class traits remain owner-defined.',
 'With an archery weapon: hit and damage modifiers each floor(level / 3).',
 '+30 effective Climbing before enhanced-climbing doubling and the applicable clamp.',
 'Reduced breath consumption: each breath decrement has a 50% chance of restoration. No failed-swimming-check fatigue penalty; ordinary swimming fatigue still applies. This is not water breathing.']
races={}
enum_src=(SRC/'Game/Entities/EntityEnums.cs').read_text()
race_enum=re.search(r'public enum Races\s*\{(.*?)\}',enum_src,re.S)[1]
picker_ids={name:int(value) for name,value in re.findall(r'(\w+)\s*=\s*(\d+)',race_enum)}
stable_ids={ident.replace('-',''):ident for ident in race_ids}
for klass,body in re.findall(r'public class (\w+) : RaceTemplate\s*\{(.*?)(?=\n    public class|\n    #endregion)',race_src,re.S):
    identity=stable_ids[klass.lower()]
    assert re.search(r'ID = \(int\)Races\.(\w+);',body)[1] == klass
    strings=dict(re.findall(r'(\w+) = "([^"]+)";',body))
    races[identity]=dict(label=re.sub(r'(?<=[a-z])(?=[A-Z])',' ',klass),picker=picker_ids[klass],description=int(re.search(r'DescriptionID = (\d+)',body)[1]),narration=int(re.search(r'ClipID = (\d+)',body)[1]),benefit=benefits[race_ids.index(identity)],appearance={gender:dict(body=strings['PaperDollBody'+gender.title()+'Unclothed'],clothed=strings['PaperDollBody'+gender.title()+'Clothed'],heads=strings['PaperDollHeads'+gender.title()],background=strings['PaperDollBackground']) for gender in ['male','female']})
abilities=[dict(kind='resistance',effect='magic'),dict(kind='weapon_modifiers',scope='non_archery_weapon',divisor=3),dict(kind='resistance',effect='frost'),dict(kind='weapon_modifiers',scope='weapon',divisor=4),dict(kind='immunity',effect='paralysis'),dict(kind='weapon_modifiers',scope='archery_weapon',divisor=3),dict(kind='effective_climbing',bonus=30,order='before_enhancement_and_clamp'),dict(kind='swimming',breath_restore_numerator=1,breath_restore_denominator=2,failed_check_fatigue_exempt=True)]
for ident, ability in zip(race_ids,abilities): races[ident]['abilities']=ability
question_src=(SRC/'Game/UserInterfaceWindows/CreateCharClassQuestions.cs').read_text()
answer_part=question_src.split('readonly byte[] answerTable = {')[1].split('};')[0]
answers=[int(n) for n in re.findall(r'\b\d+\b',answer_part)]
assert len(answers)==120 and len(races)==8 and len(traits)==90
policy=dict(schema='creation-career-v1',attributes={a:dict(start=50,min=10,max=75) for a in attributes},attribute_total=400,skills={s:dict(label=s.replace('-',' ').title(),classic=i) for i,s in enumerate(skills)},hp=dict(start=8,min=4,max=30),difficulty=dict(min=-12,max=40,low_milli=300,high_milli=3000),limits=dict(advantage=7,disadvantage=7),reputation={g:dict(start=0,min=-10,max=10) for g in ['merchants','commoners','scholars','nobility','underworld']},reputation_total=0,traits=traits,races=races,tradeoff_witness=dict(hit_points_per_level=8,traits=[]),answer_categories=[answers[i:i+3] for i in range(0,120,3)],provenance=dict(policy='CHAR-002/004/005 approved tables',metadata='Pinned DFU 1.1.1 RaceTemplate.cs, DFCareer.cs, CreateCharClassQuestions.cs (MIT)',original='Original text, map, CLASS and result bytes remain external Bethesda game data; loaded at runtime, never bundled.'))
serialized=json.dumps(dict(domain='char.career',path='policy',operation='add',entries=[dict(id='stock',value=policy)]),indent=2)+'\n'
if '--check' in sys.argv:
    assert OUT.read_text(encoding='utf-8') == serialized, 'Authored creation baseline differs from pinned metadata/tables.'
    print('Creation baseline matches pinned metadata and approved tables; no source/output files changed.')
else:
    OUT.write_text(serialized,encoding='utf-8')
