library(tidyverse)
library(RPostgreSQL)
library(sqlutils)
library(abdiv)
library(hydroTSM)

sqlutils::sqlPaths("SQL/")
db.driver <- dbDriver("PostgreSQL")
db.con <- dbConnect(db.driver, 
                    dbname = "epbx_dce_pomet",  
                    host = "citerne.bordeaux.irstea.priv",
                    port = 5432,
                    user = rstudioapi::askForPassword("user"),
                    password = rstudioapi::askForPassword("Database password"))


esp_suppression<-c('Alloteuthis subulata','Atyaephyra desmaresti,Palemon varians',
'Carcinus maenas','Chelidonichthys lucernus','Clupeidae','Cottus','Crangon',
'Crangon crangon','Dicentrarchus punctatus','Eriocheir sinensis','Hemigrapsus',
'Hemigrapsus takanoi','Orconectes limosus','Palaemon elegans','Palaemon longirostris',
'Palaemon serratus','Petromyzontidae','Phoxinus','Rhithropanopeus harrisii',
'Sepiola atlantica')


Data_POMET <- sqlutils::execQuery(query="requete_POMET",
                                  connection=db.con) |> 
  as_tibble() |> 
  mutate(date=lubridate::ymd(str_split_i(as.character(madate),pattern=" ",i=1))) |> 
  mutate_at(c("station","nom"),str_trim)  |> 
  mutate(nom=case_when(nom %in% c("Abramis")~"Abramis brama",
                       nom %in% c("Liza ramada")~"Chelon ramada",
                       nom %in% "Anguilla"~"Anguilla anguilla",
                       nom %in% c("Salmo trutta trutta", "Salmo trutta fario")~"Salmo trutta",
                       TRUE ~ nom)) |> 
  filter(experimentation %in% "DCE verveux") |> 
  mutate(saison= time2season(date,                # Convert dates to seasons
                             out.fmt = "seasons")) |> 
  mutate(mois=lubridate::month(date)) |> 
  mutate(saison=case_when(mois %in% 1:6~"printemps",
                          TRUE~"automne")) |> 
  mutate(annee=year(date)) 

Data_Dives <- Data_POMET |> 
  filter(masse_eau=="Dives")


Thresholds <- read_csv2("input/Thresholds_EBI-fr.csv")

SpMetrq <- read_csv2("input/SpeciesMetrics.csv") |> 
  janitor::clean_names() |> 
  mutate_at(c("species"),str_trim)


Data_Dives |> 
  anti_join(SpMetrq,by=c("nom"="species")) |> 
  pull(nom) |>
  unique() |> 
  sort()
## 

data_dives_step1<-Data_Dives |>
  left_join(SpMetrq,by=c("nom"="species")) |>
  filter(man_sha_fw==1) |>
  group_by(annee,saison,nom,station) |>
  summarise(ab=sum(nt)) |>
  ungroup() |>
  left_join(SpMetrq,by=c("nom"="species")) |>
  group_by(annee,saison) |>
  summarise(metric=sum(ab[str_detect("Amont",station)]))
  
  
#   group_by(annee,saison,nom) |> 
#   summarise(ab=sum(nt)) |> 
#   ungroup() |> 
#   group_by(annee,saison) |> 
#   mutate(tot=sum(ab)) |> 
#  ungroup() |> 
#   mutate(ab_rel=ab/tot)
# 
# data_dives_step1 |> 
#   group_by(annee,saison) |> 
#   summarise(ManSha=abdiv::shannon(ab))


  left_join(SpMetrq,by=c("nom"="species")) |> 
  mutate()




