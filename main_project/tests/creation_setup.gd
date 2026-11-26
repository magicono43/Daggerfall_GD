extends RefCounted
## Disposable translation qualification, never written to normal player storage.
static func configure(fixture: Dictionary) -> void:
	var root: String = str(fixture.sandbox).path_join("user/Overrides")
	preload("res://tests/publication_fixture.gd").write(root.path_join("creation-font.json"),{"domain":"text.fonts","path":"installed","operation":"add","entries":[{"id":"creation-review-french","value":{"schema":"locale-fonts-v1","kind":"locale","locale":"fr","roles":{"body":"recovery-sans","title":"recovery-sans","small-ui":"recovery-sans"},"coverage":"Controlled French label using bundled fallback font; not offered as a supported language","offer":false}}]})
	var file := FileAccess.open(root.path_join("creation-fr.csv"),FileAccess.WRITE)
	file.store_string("schema,codec,collection,locale,key,operation,base,optional,essential,placeholders,suppress,value\ntext-catalog-v1,text-token-v1,creation,fr,action.next,add,en,false,false,,false,Suivant\n")
	file.close()
