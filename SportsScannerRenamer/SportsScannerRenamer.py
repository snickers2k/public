import os
import re

def load_teams_from_file(file_path):
    teams = {}
    with open(file_path, 'r') as file:
        for line in file:
            parts = line.strip().split(':')
            if len(parts) == 2:
                teams[parts[0]] = parts[1].replace(" ", ".")
    return teams

# Bestimme den Pfad zum aktuellen Skript
script_directory = os.path.dirname(os.path.realpath(__file__))

# Lade die Team-Namen aus den Textdateien im Skript-Verzeichnis
nfl_teams = load_teams_from_file(os.path.join(script_directory, 'NFL.txt'))
nba_teams = load_teams_from_file(os.path.join(script_directory, 'NBA.txt'))

def rename_file(old_name):
    # Regex, um die relevanten Teile des Dateinamens zu erfassen
    match = re.search(r"(\w+-\w+)\.(\d{4})\.?(\d{2})\.?(\d{2})\.?(\w+)(\.At\.|\.)?(\w+)", old_name, re.IGNORECASE)
    if match:
        sport_league, year, month, day, team1, sep, team2 = match.groups()
        # Bestimme die Liga und wähle entsprechende Teamliste
        if "nfl" in sport_league.lower():
            teams = nfl_teams
            league = "NFL"
        elif "nba" in sport_league.lower():
            teams = nba_teams
            league = "NBA"
        else:
            return old_name  # Unbekannte Liga

        # Ersetze Kürzel durch vollständige Namen und ersetze Leerzeichen durch Punkte
        full_team1 = teams.get(team1.title(), team1)
        full_team2 = teams.get(team2.title(), team2)
        # Generiere den neuen Namen
        new_name = f"{league}.{year}-{month}-{day}.{full_team1}.vs.{full_team2}.mkv"
        return new_name
    return old_name

def rename_files_in_directory(directory):
    for filename in os.listdir(directory):
        new_name = rename_file(filename)
        if new_name != filename:
            old_path = os.path.join(directory, filename)
            new_path = os.path.join(directory, new_name)
            os.rename(old_path, new_path)
            print(f"{filename} -> {new_name}")

# Pfad zum Verzeichnis (anpassen an das gewünschte Verzeichnis)
directory_path = '/pfad/zum/verzeichnis'
rename_files_in_directory(directory_path)
