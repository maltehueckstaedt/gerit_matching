# GERIT PRE-Matching mit OpenAI-Embeddings

## Projektbeschreibung
Dieses Repository enthält ein R-Wrapper, der ein Python-Skript umschließt, das das Cleaning für das bishere Matching-Vorgehen weitestgehend erübrigt.

Statt klassischer Datenbereinigung und anschließendem Matching, wird ein vektorbasierter Ansatz mit OpenAI-Embeddings genutzt, um eine effizientere und robustere Zuordnung zu ermöglichen.

## Funktionsweise
1. **Daten laden:** Die Rohdaten aus dem Scraping und GERIT-Referenzdaten werden eingelesen.
2. **Erstellung von Embeddings:** 
   - Die GERIT-Organisationsnamen werden mit OpenAI-Embeddings (`text-embedding-3-large`) in Vektoren umgewandelt.
   - Eine In-Memory-Vektordatenbank wird erstellt, um Ähnlichkeitsabfragen effizient durchzuführen.
3. **Matching-Mechanismus:** 
   - Es wird ein `Retriever` mit Fuzzy Matching verwendet, um eine bestmögliche Zuordnung vorzunehmen (basierend auf einem Ähnlichkeitsscore).
   - Ein Score-Cutoff (standardmäßig >0.65) steuert die Qualität der Zuordnung. Ein Score von `1` ist ein bestmöglicher match.
4. **Rückspielung der Ergebnisse:** 
   - Die gematchten GERIT-Namen, Matching-Scores und Matching-Typen werden an den ursprünglichen DataFrame angefügt.
   - `None`-Werte werden in `NaN` konvertiert, um eine problemlose Integration in R zu ermöglichen.

## Vorteile
-  Schnelligkeit: 20.000 Zeilen mit 250 einzigartigen Werten werden in etwa 1,5 Minuten verarbeitet.  
- Automatisiert: Keine aufwendige Datenbereinigung nötig.  
- Anpassbar: Der Ähnlichkeitsschwellenwert kann je nach Anwendungsfall optimiert werden.  
- **R-Integration:** Durch den R-Wrapper kann die Funktion direkt in einer R-Umgebung genutzt werden.  

## Nachteile
- Die Qualität der Zuordnung muss geprüft werden.  
- Auswirkungen auf nachfolgende Analysen sollten untersucht werden.  

## Installation und Nutzung
### Voraussetzungen: Conda Enviorment

Um den Wrapper verwenden zu können, muss ein eigens für die Anwendung des Wrappers erzeugtes Conda-Environment installiert werden. 

1. [gerit_match.yaml](gerit_match.yml) downladen.
2. Laden und Installieren von Miniconda: https://docs.anaconda.com/miniconda/
2. Den Anaconda-Terminal öffnen (zu finden, in dem man in der Taskleiste nach *Anaconda* sucht)
3. Das Environment erzeugen: `conda env create -f gerit_match.yaml`. Wenn das .yaml nicht in dem gleichen Pfad befindlich ist, wie der, in dem der Anaconda-Terminal ist: Pfad spezifizieren. Zum Beispiel so: `conda env create -f C:\Users\mhu\Downloads\gerit_match.yml`

### Verwendung

Um den Wrapper zu verwenden, laden wir in einem ersten Schritt die Pakete `reticulate` und `tidyverse`. Weiterhin spezifizieren wir den Pfad zu unserer Miniconda und das oben installierte Environment. Die Ort, an dem die Miniconda liegt, finden wir, in dem wir in unseren Anaconda-Terminal gehen, und dort den Befehl `conda info` eingeben und unter `base environment` schauen.
Schließlich öffnen wir mit `file.edit("~/.Renviron")` unser `.Renviron` File und setzen unseren OpenAI-API-Key in in folgender Form: `OPENAI_API_KEY="DEIN_KEY"`. Wir speichern und schließen den Editor.

```r
library(reticulate)
library(tidyverse)
Sys.setenv(RETICULATE_MINICONDA_PATH = "D:/Programme/miniconda")
use_condaenv("gerit_match", required = TRUE)
file.edit("~/.Renviron")
```

Wir laden weiterhin die Python-Funktion, die das Matching durchführt sowie unseren R-Wrapper, der die Python-Funktion umschließt. Wir laden ebenfalls das Eingangsmaterial `df_scraped` und `df_gerit` in den Workspace. Nun kann das Matching mit `gerit_match_r_wrapper()` vollzogen  und die die resultierenden Daten exportiert werden.

```r
# Lade das Python-Skript
source_python("py/gerit_matching.py")
source("R/gerit_match_r_wrapper.R")

scraped_df <- readRDS("data/df_scraped.rds")
gerit_df <- readRDS("data/df_gerit.rds")

# Matching durchführen
gerit_df_matched <- gerit_match_r_wrapper(scraped_df, gerit_df)

# Daten exportieren
write_rds(gerit_df_matched,"data/gerit_df_matched.rds")
```

## Matching-Details
Das Matching erfolgt über eine Retriever-Funktion, die nach Ähnlichkeiten sucht:
- **Retriever-Mechanismus:**
  - Durchsucht GERIT-Organisationen nach der besten Übereinstimmung
  - Gibt einen cosinusbasierten Ähnlichkeitsscore des Langchain-Paketes zurück
- **Matching-Funktion:**
  - Falls eine Übereinstimmung mit Score >0.65 gefunden wird, wird der GERIT-Name übernommen
  - Falls keine passende Entsprechung existiert, wird `NA` vergeben.

## Beispielergebnis
| Ursprünglicher Wert        | Gematchter GERIT-Wert      | Matching-Art | Score  |
|----------------------------|---------------------------|--------------|--------|
| Institut für Physikalische Chemie und Elektrochemie      | Institut für Physikalische Chemie      | Fuzzy        | 0.86   |
| Lehrstuhl für Betriebswirtschaftslehre, insbes. Financial Accounting   | Lehrstuhl für BWL, insb. Accounting       | Fuzzy        | 0.92   |
| Abteilung für Informationswissenschaft           | Abteilung für Informationswissenschaft           | Fuzzy        | 1.00   |


