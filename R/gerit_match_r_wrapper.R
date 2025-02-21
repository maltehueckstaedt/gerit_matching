gerit_match_r_wrapper <- function(scraped_df, gerit_df) {

  # Konvertiere R-Dataframes zu pandas-DataFrames
  scraped_pd <- r_to_py(scraped_df)
  gerit_pd <- r_to_py(gerit_df)

  # Python-Funktion aufrufen
  matched_pd <- match_organisations(scraped_pd, gerit_pd)

  # reduziere aus funktion resultierenden df auf relevanten
  # Variablen
  join_df <- matched_pd |>
    select(organisation_names_for_matching_back,
           gerit_organisation, Score, "Matching-Art")

  # Entferne aus scraped_df gerit_organisation um doppelung
  # beim mergen zu vermeiden
  scraped_df <- scraped_df |> select(-gerit_organisation)

  # Merge scraped_df mit join_df
  gerit_df_matched <- left_join(scraped_df, join_df, by = "organisation_names_for_matching_back")

  return(gerit_df_matched)
}
