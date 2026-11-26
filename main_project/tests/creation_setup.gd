extends RefCounted
## Disposable translation qualification, never written to normal player storage.
static func configure(fixture: Dictionary) -> void:
	# Interactive review uses stock English content. Localization stress belongs
	# only to the automated creation suite, in its separate disposable storage.
	if fixture.get("mode") != "creation-draft": return
	var root: String = str(fixture.sandbox).path_join("user/Overrides")
	preload("res://tests/publication_fixture.gd").write(root.path_join("creation-font.json"),{"domain":"text.fonts","path":"installed","operation":"add","entries":[{"id":"creation-review-french","value":{"schema":"locale-fonts-v1","kind":"locale","locale":"fr","roles":{"body":"recovery-sans","title":"recovery-sans","small-ui":"recovery-sans"},"coverage":"Controlled French label using bundled fallback font; not offered as a supported language","offer":false}}]})
	var file := FileAccess.open(root.path_join("creation-fr.csv"),FileAccess.WRITE)
	file.store_string("schema,codec,collection,locale,key,operation,base,optional,essential,placeholders,suppress,value\ntext-catalog-v1,text-token-v1,creation,fr,action.next,add,en,false,false,,false,Suivant\n")
	file.close()
	# Real loose DATA override before publication: long localized question text
	# and unsupported glyph recovery, with every original mechanical field intact.
	var source: String = str(fixture.classic_source).path_join("BIOG00T0.TXT")
	var decoded := preload("res://scripts/data/actor_input_formats.gd").biography(FileAccess.get_file_as_bytes(source),source)
	if decoded.ok:
		var biography: Dictionary = decoded.records.biography.duplicate(true)
		biography.erase("kind")
		biography.questions[0].text = "Au cours de votre enfance, quelle école de magie avez-vous étudiée le plus longtemps ? Cette question de qualification conserve toutes les réponses et tous leurs effets, tout en vérifiant le défilement, la lisibilité et la récupération de police dans le véritable écran de biographie. 記憶"
		preload("res://tests/publication_fixture.gd").write(root.path_join("biography-localized.json"),{"domain":"actor.inputs","path":"catalog","operation":"patch","entries":[{"id":"biog00t0","value":{"data":biography}}]})
