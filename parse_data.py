import json
from pathlib import Path
import tempfile


def load_items(filename):
    """Read the item list rather than returning the outer JSON object."""
    with open(filename, encoding="utf-8") as file:
        data = json.load(file)
    if not isinstance(data, dict) or not isinstance(data.get("items"), list):
        raise ValueError("The database must contain an 'items' list.")
    if not all(isinstance(item, dict) for item in data["items"]):
        raise ValueError("Each item in the database must be an object.")
    return data["items"]


def get_unclaimed_items(items):
    return [item for item in items if item.get("status") == "unclaimed"]


def save_result(result, filename):
    path = Path(filename)
    content = json.dumps(result, indent=4, ensure_ascii=False) + "\n"
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary_path = None
    try:
        # Replace only after a complete write, preserving the previous result on failure.
        with tempfile.NamedTemporaryFile(
            mode="w", encoding="utf-8", dir=path.parent, delete=False
        ) as file:
            temporary_path = Path(file.name)
            file.write(content)
        temporary_path.replace(path)
    finally:
        if temporary_path is not None:
            temporary_path.unlink(missing_ok=True)
