class_name StartupProviderBoundary
extends RefCounted
## IMP-004/005 replace these unavailability results with real checked providers.
## A result carries source/reason. No directory guess is accepted as validation.
func check_classic(candidate: String) -> Dictionary:
	return {"ok": false, "source": candidate, "reason": "Classic data validation is unavailable in this build. Content support is required to continue."}

func publish_packages(_classic: Dictionary) -> Dictionary:
	return {"ok": false, "source": "packages", "reason": "Content package preparation is unavailable in this build. Content support is required to continue."}

func open_menu() -> Dictionary:
	return {"ok": true}
