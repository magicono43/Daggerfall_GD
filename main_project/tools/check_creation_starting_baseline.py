"""Offline source/provenance audit; not a game or exported runtime dependency."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTENT = ROOT / "main_project/content/char"
RESOURCES = ROOT / "reference_material/daggerfall-unity-1.1.1-cve-2025/Assets/Resources"


def policy(name):
    return json.loads((CONTENT / name).read_text(encoding="utf-8-sig"))["entries"][0]["value"]


def main():
    biography = policy("biography.json")
    starting = policy("starting.json")
    name_bytes = (RESOURCES / "NameGen.txt").read_bytes()
    book_bytes = (RESOURCES / "books.txt").read_bytes()
    # Eight supported humanoid banks precede unrelated monster data. The pinned
    # Monster3 block is malformed JSON and is neither repaired nor used here.
    prefix = name_bytes.decode("utf-8-sig").split('"Monster1"', 1)[0].rstrip().rstrip(",") + "}"
    names = json.loads(prefix)
    books_text = book_bytes.decode("utf-8-sig").rstrip()
    assert books_text.endswith(",\n]"), "Pinned books source trailing-comma profile changed"
    books = json.loads(books_text[:-3] + "\n]")
    banks = {key: [row["parts"] for row in names[key]["sets"]] for key in
             ("Breton", "Redguard", "Nord", "DarkElf", "HighElf", "WoodElf", "Khajiit", "Imperial")}
    assert biography["name_banks"] == banks
    assert biography["books"] == [row["id"] for row in books if row["id"] not in (112, 113)]
    assert len(biography["books"]) == 90
    assert {row["id"] for row in biography["provenance"]["book_exclusions"]} == {112, 113}
    for field, source in (("name_sha256", name_bytes), ("books_sha256", book_bytes)):
        assert biography["provenance"][field] == hashlib.sha256(source).hexdigest().upper()
    assert biography["order"] == [f"class-{index:02}" for index in range(18)]
    for index in range(18):
        assert biography["mappings"][f"class-{index:02}"] == [f"biog{index:02}t0"]
        assert biography["narratives"][f"biog{index:02}t0"] == f"text-{4116+index}"
    item_mappings = json.loads((ROOT / "main_project/content/items/dfu-item-mappings.json").read_text())
    assert biography["items"] == {key: f"dfu-item-{value:03}" for key, value in item_mappings.items()}
    assert starting["attributes"]["pool"] == {"min": 6, "max": 14}
    assert len(starting["attributes"]["values"]) == 8
    assert all(row == {"bonus": {"min": 0, "max": 10}, "cap": 100}
               for row in starting["attributes"]["values"].values())
    assert starting["skills"]["ranges"] == {key: {"min": low, "max": high} for key, low, high in
                                           (("primary", 28, 31), ("major", 18, 21), ("minor", 13, 16), ("other", 3, 6))}
    assert starting["skills"]["pools"] == {key: 6 for key in ("primary", "major", "minor")}
    assert len(starting["skills"]["limits"]) == 35
    assert all(row == {"min": 0, "max": 100} for row in starting["skills"]["limits"].values())
    print("PASS: creation starting/biography baseline, mappings, 90 books, eight name banks and source hashes")


if __name__ == "__main__":
    main()
