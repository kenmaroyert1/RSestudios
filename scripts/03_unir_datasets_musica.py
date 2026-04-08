import csv
from pathlib import Path

BASE = Path(__file__).resolve().parents[1]
RAW = BASE / "data" / "raw" / "music"
OUT = BASE / "data" / "processed" / "music" / "spotify_dataset_unificado.csv"

INPUT_FILES = [
    RAW / "spotify_alltime_top100_songs.csv",
    RAW / "spotify_wrapped_2025_top50_artists.csv",
    RAW / "spotify_wrapped_2025_top50_songs.csv",
]


def read_rows(path: Path):
    with path.open("r", encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f)
        rows = list(reader)
        return reader.fieldnames or [], rows


def main():
    all_headers = []
    all_rows = []

    for file_path in INPUT_FILES:
        if not file_path.exists():
            raise FileNotFoundError(f"No existe: {file_path}")

        headers, rows = read_rows(file_path)

        for h in headers:
            if h not in all_headers:
                all_headers.append(h)

        for r in rows:
            r["source_file"] = file_path.name
            if "artist_name" in r and r.get("artist_name"):
                r["record_type"] = "artist"
            else:
                r["record_type"] = "song"
            all_rows.append(r)

    for extra in ["source_file", "record_type"]:
        if extra not in all_headers:
            all_headers.append(extra)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    with OUT.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=all_headers, extrasaction="ignore")
        writer.writeheader()
        for row in all_rows:
            normalized = {k: row.get(k, "") for k in all_headers}
            writer.writerow(normalized)

    print(f"Archivo unificado generado: {OUT}")
    print(f"Total filas: {len(all_rows)}")
    print(f"Total columnas: {len(all_headers)}")


if __name__ == "__main__":
    main()
