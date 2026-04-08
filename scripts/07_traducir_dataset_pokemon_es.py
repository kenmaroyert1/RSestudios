from pathlib import Path
import json
import re
import time
from typing import Dict, Optional

import pandas as pd
import requests

ROOT = Path(__file__).resolve().parents[1]
INPUT_PATH = ROOT / "pokemon_complete_2025.csv"
OUTPUT_PATH = ROOT / "data" / "processed" / "pokemon" / "pokemon_complete_2025_es.csv"
OUTPUT_XLSX_PATH = ROOT / "data" / "processed" / "pokemon" / "pokemon_complete_2025_es.xlsx"
CACHE_DIR = ROOT / "data" / "processed" / "pokemon" / "cache_es"
SPECIES_CACHE_PATH = CACHE_DIR / "species_cache.json"
ABILITY_CACHE_PATH = CACHE_DIR / "ability_cache.json"

COLUMN_MAP = {
    "pokedex_id": "id_pokedex",
    "name": "nombre",
    "genus": "especie",
    "generation": "generacion",
    "type_1": "tipo_1",
    "type_2": "tipo_2",
    "num_types": "numero_tipos",
    "hp": "ps",
    "attack": "ataque",
    "defense": "defensa",
    "sp_attack": "ataque_especial",
    "sp_defense": "defensa_especial",
    "speed": "velocidad",
    "base_stat_total": "total_estadisticas_base",
    "height_m": "altura_m",
    "weight_kg": "peso_kg",
    "base_experience": "experiencia_base",
    "ability_1": "habilidad_1",
    "ability_2": "habilidad_2",
    "hidden_ability": "habilidad_oculta",
    "color": "color",
    "shape": "forma",
    "habitat": "habitat",
    "growth_rate": "ritmo_crecimiento",
    "egg_groups": "grupos_huevo",
    "is_legendary": "es_legendario",
    "is_mythical": "es_mitico",
    "is_baby": "es_bebe",
    "capture_rate": "tasa_captura",
    "base_happiness": "felicidad_base",
    "hatch_counter": "contador_eclosion",
    "gender_rate": "tasa_genero",
    "description": "descripcion",
    "sprite_url": "url_sprite",
    "is_dual_type": "es_tipo_dual",
    "bmi": "imc",
    "attack_defense_ratio": "proporcion_ataque_defensa",
    "physical_total": "total_fisico",
    "special_total": "total_especial",
    "offensive_total": "total_ofensivo",
    "defensive_total": "total_defensivo",
    "gender_distribution": "distribucion_genero",
    "stat_tier": "nivel_estadisticas",
}

TYPE_MAP = {
    "normal": "normal",
    "fire": "fuego",
    "water": "agua",
    "electric": "electrico",
    "grass": "planta",
    "ice": "hielo",
    "fighting": "lucha",
    "poison": "veneno",
    "ground": "tierra",
    "flying": "volador",
    "psychic": "psiquico",
    "bug": "bicho",
    "rock": "roca",
    "ghost": "fantasma",
    "dragon": "dragon",
    "dark": "siniestro",
    "steel": "acero",
    "fairy": "hada",
}

COLOR_MAP = {
    "black": "negro",
    "blue": "azul",
    "brown": "marron",
    "gray": "gris",
    "green": "verde",
    "pink": "rosa",
    "purple": "morado",
    "red": "rojo",
    "white": "blanco",
    "yellow": "amarillo",
}

SHAPE_MAP = {
    "armor": "armadura",
    "arms": "brazos",
    "ball": "bola",
    "blob": "masa",
    "bug-wings": "alas_insecto",
    "fish": "pez",
    "heads": "cabezas",
    "humanoid": "humanoide",
    "legs": "piernas",
    "quadruped": "cuadrupedo",
    "squiggle": "serpentino",
    "tentacles": "tentaculos",
    "upright": "erguido",
    "wings": "alas",
}

HABITAT_MAP = {
    "cave": "cueva",
    "forest": "bosque",
    "grassland": "pradera",
    "mountain": "montana",
    "rare": "raro",
    "rough-terrain": "terreno_aspero",
    "sea": "mar",
    "urban": "urbano",
    "waters-edge": "orilla_agua",
}

GROWTH_RATE_MAP = {
    "fast": "rapido",
    "medium": "medio",
    "medium-fast": "medio_rapido",
    "medium-slow": "medio_lento",
    "slow": "lento",
    "fluctuating": "fluctuante",
    "erratic": "erratico",
}

EGG_GROUP_MAP = {
    "amorphous": "amorfo",
    "bug": "bicho",
    "ditto": "ditto",
    "dragon": "dragon",
    "fairy": "hada",
    "field": "campo",
    "flying": "volador",
    "grass": "planta",
    "ground": "tierra",
    "human-like": "humanoide",
    "humanshape": "humanoide",
    "indeterminate": "indeterminado",
    "mineral": "mineral",
    "monster": "monstruo",
    "no-eggs": "sin_huevos",
    "plant": "planta",
    "water1": "agua1",
    "water2": "agua2",
    "water3": "agua3",
}

STAT_TIER_MAP = {
    "Weak (<300)": "Debil (<300)",
    "Below Average (300-399)": "Debajo del promedio (300-399)",
    "Average (400-499)": "Promedio (400-499)",
    "Strong (500-599)": "Fuerte (500-599)",
    "Legendary/Pseudo (600+)": "Legendario/Pseudo (600+)",
}

BOOLEAN_MAP = {
    "True": "Verdadero",
    "False": "Falso",
    True: "Verdadero",
    False: "Falso",
}


def load_json_cache(path: Path) -> Dict[str, dict]:
    if not path.exists():
        return {}
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def save_json_cache(path: Path, data: Dict[str, dict]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def normalize_text(text: str) -> str:
    text = text.replace("\n", " ").replace("\f", " ")
    return re.sub(r"\s+", " ", text).strip()


def get_spanish_field(entries: list, field_name: str) -> Optional[str]:
    for entry in entries:
        language = entry.get("language", {}).get("name")
        if language == "es":
            value = entry.get(field_name)
            if isinstance(value, str) and value.strip():
                return normalize_text(value)
    return None


def fetch_json(session: requests.Session, url: str, retries: int = 3, sleep_s: float = 0.25) -> dict:
    last_err = None
    for _ in range(retries):
        try:
            response = session.get(url, timeout=20)
            response.raise_for_status()
            return response.json()
        except Exception as err:  # noqa: BLE001
            last_err = err
            time.sleep(sleep_s)
    raise RuntimeError(f"No se pudo consultar {url}: {last_err}")


def roman_to_num(roman: str) -> str:
    mapping = {
        "I": "1",
        "II": "2",
        "III": "3",
        "IV": "4",
        "V": "5",
        "VI": "6",
        "VII": "7",
        "VIII": "8",
        "IX": "9",
    }
    return mapping.get(roman, roman)


def fetch_species_translation(
    session: requests.Session,
    species_cache: Dict[str, dict],
    pokedex_id: int,
    fallback_name: str,
    fallback_genus: str,
    fallback_description: str,
    fallback_generation: str,
) -> dict:
    key = str(pokedex_id)
    if key in species_cache:
        return species_cache[key]

    url = f"https://pokeapi.co/api/v2/pokemon-species/{pokedex_id}"
    data = fetch_json(session, url)

    name_es = get_spanish_field(data.get("names", []), "name") or fallback_name
    genus_es = get_spanish_field(data.get("genera", []), "genus") or fallback_genus
    flavor_es = get_spanish_field(data.get("flavor_text_entries", []), "flavor_text") or fallback_description

    generation_name = data.get("generation", {}).get("name", "")
    if generation_name.startswith("generation-"):
        generation_suffix = generation_name.replace("generation-", "").upper()
        generation_es = f"Generacion {roman_to_num(generation_suffix)}"
    else:
        generation_es = f"Generacion {roman_to_num(fallback_generation)}"

    translated = {
        "nombre": name_es,
        "especie": genus_es,
        "descripcion": flavor_es,
        "generacion": generation_es,
    }
    species_cache[key] = translated
    return translated


def fallback_translate_slug(text: str) -> str:
    return text.replace("-", " ").replace("_", " ").strip()


def fetch_ability_translation(session: requests.Session, ability_cache: Dict[str, str], ability_name: str) -> str:
    if not ability_name or not isinstance(ability_name, str):
        return ability_name

    key = ability_name.strip().lower()
    if not key:
        return ability_name
    if key in ability_cache:
        return ability_cache[key]

    url = f"https://pokeapi.co/api/v2/ability/{key}"
    try:
        data = fetch_json(session, url)
        name_es = get_spanish_field(data.get("names", []), "name")
        translated = name_es if name_es else fallback_translate_slug(key)
    except Exception:  # noqa: BLE001
        translated = fallback_translate_slug(key)

    ability_cache[key] = translated
    return translated


def translate_simple(value, mapping):
    if pd.isna(value):
        return value
    text = str(value).strip()
    return mapping.get(text, text)


def translate_comma_list(value, mapping):
    if pd.isna(value):
        return value
    parts = [item.strip() for item in str(value).split(",")]
    translated = [mapping.get(item, item) for item in parts]
    return ", ".join(translated)


def translate_gender_distribution(value):
    if pd.isna(value):
        return value
    text = str(value)
    text = text.replace("Always Male", "Siempre macho")
    text = text.replace("Always Female", "Siempre hembra")
    text = text.replace("Genderless", "Sin genero")
    text = re.sub(r"Male", "Macho", text)
    text = re.sub(r"Female", "Hembra", text)
    return text


def main():
    if not INPUT_PATH.exists():
        raise FileNotFoundError(f"No se encontro el archivo de entrada: {INPUT_PATH}")

    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    species_cache = load_json_cache(SPECIES_CACHE_PATH)
    ability_cache = load_json_cache(ABILITY_CACHE_PATH)

    df = pd.read_csv(INPUT_PATH)

    with requests.Session() as session:
        session.headers.update({"User-Agent": "dataset-traductor-es/1.0"})

        for idx, row in df.iterrows():
            translated = fetch_species_translation(
                session=session,
                species_cache=species_cache,
                pokedex_id=int(row["pokedex_id"]),
                fallback_name=str(row.get("name", "")),
                fallback_genus=str(row.get("genus", "")),
                fallback_description=str(row.get("description", "")),
                fallback_generation=str(row.get("generation", "")),
            )
            df.at[idx, "name"] = translated["nombre"]
            df.at[idx, "genus"] = translated["especie"]
            df.at[idx, "description"] = translated["descripcion"]
            df.at[idx, "generation"] = translated["generacion"]

            if (idx + 1) % 100 == 0:
                print(f"Traducidos {idx + 1} pokemon...")

        for col in ["ability_1", "ability_2", "hidden_ability"]:
            if col in df.columns:
                df[col] = df[col].apply(
                    lambda x: fetch_ability_translation(session, ability_cache, x) if pd.notna(x) else x
                )

    for col in ["type_1", "type_2"]:
        if col in df.columns:
            df[col] = df[col].apply(lambda x: translate_simple(x, TYPE_MAP))

    if "color" in df.columns:
        df["color"] = df["color"].apply(lambda x: translate_simple(x, COLOR_MAP))

    if "shape" in df.columns:
        df["shape"] = df["shape"].apply(lambda x: translate_simple(x, SHAPE_MAP))

    if "habitat" in df.columns:
        df["habitat"] = df["habitat"].apply(lambda x: translate_simple(x, HABITAT_MAP))

    if "growth_rate" in df.columns:
        df["growth_rate"] = df["growth_rate"].apply(lambda x: translate_simple(x, GROWTH_RATE_MAP))

    if "egg_groups" in df.columns:
        df["egg_groups"] = df["egg_groups"].apply(lambda x: translate_comma_list(x, EGG_GROUP_MAP))

    if "stat_tier" in df.columns:
        df["stat_tier"] = df["stat_tier"].apply(lambda x: translate_simple(x, STAT_TIER_MAP))

    for col in ["is_legendary", "is_mythical", "is_baby", "is_dual_type"]:
        if col in df.columns:
            df[col] = df[col].apply(lambda x: BOOLEAN_MAP.get(x, x))

    if "gender_distribution" in df.columns:
        df["gender_distribution"] = df["gender_distribution"].apply(translate_gender_distribution)

    if "name" in df.columns:
        df["name"] = df["name"].apply(lambda x: str(x).title() if pd.notna(x) else x)

    df = df.rename(columns=COLUMN_MAP)

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(OUTPUT_PATH, index=False, encoding="utf-8-sig")
    df.to_excel(OUTPUT_XLSX_PATH, index=False)

    save_json_cache(SPECIES_CACHE_PATH, species_cache)
    save_json_cache(ABILITY_CACHE_PATH, ability_cache)

    print(f"Archivo generado: {OUTPUT_PATH}")
    print(f"Archivo generado: {OUTPUT_XLSX_PATH}")


if __name__ == "__main__":
    main()
