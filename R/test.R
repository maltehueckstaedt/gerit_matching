library(reticulate)
library(tidyverse)
#Sys.setenv(RETICULATE_CONDA_BINARY = "D:/Programme/miniconda/condabin/conda.bat")
Sys.setenv(RETICULATE_MINICONDA_PATH = "D:/Programme/miniconda")
use_condaenv("gerit_match", required = TRUE)
#file.edit("~/.Renviron")

# Lade das Python-Skript
source_python("py/gerit_matching.py")

# R-Funktion für das GERIT-Matching
gerit_match <- function(scraped_df, gerit_df) {

  # Konvertiere R-Dataframes zu pandas-DataFrames
  scraped_pd <- r_to_py(scraped_df)
  gerit_pd <- r_to_py(gerit_df)

  # Python-Funktion aufrufen
  matched_pd <- match_organisations(scraped_pd, gerit_pd)
  matched_pd <- join_df <- matched_pd |> select(organisation_names_for_matching_back, gerit_organisation, Score, "Matching-Art")
  scraped_df <- scraped_df |> select(-gerit_organisation)
  gerit_df_matched <- left_join(scraped_df, join_df, by = "organisation_names_for_matching_back")

  return(gerit_df_matched)
}


scraped_df <- readRDS("data/df_scraped.rds")
gerit_df <- readRDS("data/df_gerit.rds")
colnames(scraped_df)

# Matching durchführen
gerit_df_matched <- gerit_match(scraped_df, gerit_df)
write_rds(gerit_df_matched,"data/gerit_df_matched.rds")
