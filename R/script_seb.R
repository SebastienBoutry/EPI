library(tidyverse)


Data_Dives <- read_csv2("input/Data_Dives.csv") |> 
  mutate_at(c("station","nom"),str_trim)  |> 
  mutate(nom=case_when(nom %in% c("Abramis")~"Abramis brama",
                       nom %in% c("Liza ramada")~"Chelon ramada",
                       nom %in% "Anguilla"~"Anguilla anguilla",
                       nom %in% c("Salmo trutta trutta", "Salmo trutta fario")~"Salmo trutta",
                       TRUE ~ nom))


Thresholds <- read_csv2("input/Thresholds_EBI-fr.csv")

SpMetrq <- read_csv2("input/SpeciesMetrics.csv") |> 
  janitor::clean_names() |> 
  mutate_at(c("species"),str_trim)


Data_Dives |> 
  anti_join(SpMetrq,by=c("nom"="species")) |> 
  pull(nom) |> unique() |> 
  sort()

