library(reticulate)
library(tidyverse)
install.packages("reticulate")#Sys.setenv(RETICULATE_CONDA_BINARY = "D:/Programme/miniconda/condabin/conda.bat")
Sys.setenv(RETICULATE_MINICONDA_PATH = "D:/Programme/miniconda")
use_condaenv("gerit_match", required = TRUE)
#file.edit("~/.Renviron")

# Lade das Python-Skript
source_python("py/gerit_matching.py")
source("R/gerit_match_r_wrapper.R")

scraped_df <- readRDS("data/df_scraped.rds")
gerit_df <- readRDS("data/df_gerit.rds")

# Matching durchführen
gerit_df_matched <- gerit_match_r_wrapper(scraped_df, gerit_df)

# Daten exportieren
write_rds(gerit_df_matched,"data/gerit_df_matched.rds")