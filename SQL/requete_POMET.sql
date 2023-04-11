-- !preview conn=DBI::dbConnect(RSQLite::SQLite())
SELECT trait_id, experimentation, fk_materiel_id, madate, station, pos_deb_lat_dd,
pos_deb_long_dd, pos_fin_lat_dd, pos_fin_long_dd, distance_chalutee, duree,
nt, pt, espece.nom, nom_fr, engin, masse_eau, salinite_classe, systeme
FROM trait, echantillon, espece, campagnes, masse_eau
WHERE trait.trait_id = echantillon.fk_trait_id AND 
echantillon.espece_id = espece.espece_id AND 
trait.fk_campagne_id = campagnes.campagne_id AND 
campagnes.fk_masse_eau = masse_eau.masse_eau_id;
                              
