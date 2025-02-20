library(hexmatch)
find_names()

setup_matching(name_gerit = "Heinrich-Heine-Universität Düsseldorf", 
               name_folder = "Heinrich-Heine-Universitaet_Duesseldorf", 
               name_rds = "data_heinrich_heine_universitaet_duesseldorf.rds" ,
               with_organisation_alternativ = FALSE)

# voraussetzung: data_heinrich_heine_universitaet_duesseldorf.rds im enviorment.
# Wichtige Variablen: df_gerit: Variable: Einrichtung=Gerit kleinste Orga-Einheit
# df_scraped: organisation_names_for_matching_back: Orga-Namen, die aus dem ScrAPING kommen. Gemachte wete in "gerit_organisation" schreiben
# In df_scraped: organisation_type_for_matching "combinations" rausfiltern. 
#nach dem Matching: is_luf_unique: rausfiltern.
