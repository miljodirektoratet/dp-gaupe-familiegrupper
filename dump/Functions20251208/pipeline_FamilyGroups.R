# This script calculates the number of family groups 

rm(list=ls()) # Clear workspace

library(s2)
library(sf)
library(plyr)
library(dplyr)
library(tictoc)
library(arrow)
library(leaflet)
library(mapview)
library(leaflet.extras2)
library(viridis)
library(htmlwidgets)

source("/home/rstudio/workspace/dump/Functions20251208/Functions/Function_GroupLynxOld_MultipleStart_Ver2.R")
source("/home/rstudio/workspace/dump/Functions20251208/Functions/Function_GroupLynxOld_Ver2.R")

################################################################################
# ----------- Inspect data
################################################################################


dat_pnt <- read_parquet("/home/rstudio/workspace/dump/hidden/data/rovviltobservasjon_punkt.geoparquet")
dat_spor <- read_parquet("/home/rstudio/workspace/dump/hidden/data/rovviltobservasjon_spor.geoparquet")
dat_spor_pnt <- read_parquet("/home/rstudio/workspace/dump/hidden/data/rovviltobservasjon_spor_pnt.geoparquet")
dod <- read_parquet("/home/rstudio/workspace/dump/hidden/data/doderovdyr_punkt.geoparquet")
datagrunnlag <- read_parquet("/home/rstudio/workspace/dump/hidden/data/gaupe_familiegrupper_datagrunnlag.geoparquet")

# Convert geometry
dod$geometry <- st_as_sfc(structure(as.list(dod$geometri_wkb), class = "WKB"), crs=3006)
dat_pnt$geometry <- st_as_sfc(structure(as.list(dat_pnt$geometri_wkb), class = "WKB"), crs=3006)
dat_spor$geometry <- st_as_sfc(structure(as.list(dat_spor$geometri_wkb), class = "WKB"), crs=3006)
dat_spor_pnt$geometry <- st_as_sfc(structure(as.list(dat_spor_pnt$geometri_wkb), class = "WKB"), crs=3006)
datagrunnlag$geometry <- st_as_sfc(structure(as.list(datagrunnlag$geometri_wkb), class = "WKB"), crs=3006)

dod<-st_as_sf(dod)
dat_pnt<-st_as_sf(dat_pnt)
dat_spor<-st_as_sf(dat_spor)

plot(datagrunnlag$geometry)

# Check if all RovbaseID is in datagrunnlag
all(c(unique(dat_pnt$rovbase_id), unique(dod$rovbase_id))%in%unique(datagrunnlag$rovbase_id))

# Give datagrunnlag a shorter name and make it spatial
dat<-st_as_sf(datagrunnlag)

# Fixing time
dat[is.na(dat$aktivitetsdato_fra),]$aktivitetsdato_fra<-dat[is.na(dat$aktivitetsdato_fra),]$doedsdato
dat[is.na(dat$aktivitetsdato_til),]$aktivitetsdato_til<-dat[is.na(dat$aktivitetsdato_til),]$doedsdato

dat[is.na(dat$aktivitetstid_fra),]$aktivitetstid_fra<-"00:00"
dat[is.na(dat$aktivitetstid_til),]$aktivitetstid_til<-"23:59"

dat$datetime1<-as.POSIXct(paste0(dat$aktivitetsdato_fra, " ", dat$aktivitetstid_fra), tz="CET", format="%Y-%m-%d %H:%M")
dat$datetime2<-as.POSIXct(paste0(dat$aktivitetsdato_til, " ", dat$aktivitetstid_til), tz="CET", format="%Y-%m-%d %H:%M")

# Grouping by RovbaseID and casting as multipoint for snow tracks
dat<-st_as_sf(dat)

dat<-dat %>%
  group_by(rovbase_id) %>% 
  summarize(geometry = st_union(geometry),
            datetime1 = datetime1[1],
            datetime2 = datetime2[1])

dat<-st_cast(dat, "MULTIPOINT")

# Extract prey class
prey<-st_read("Data/byttedyrkategori_skandinavia_tettede_hull.shp")
ind<-st_intersects(dat, st_transform(prey, 3006))

dat$prey<-NA
dat[which(lengths(ind)==1),]$prey<-prey[unlist(ind[which(lengths(ind)==1)]),]$Kategori

for(ii in which(lengths(ind)>1)){
  dat[ii,]$prey<-prey[unlist(ind[which(lengths(ind)>1)]),]
}

fam_groups<-grouplynx_diff_starts(RovbaseID = dat$rovbase_id, 
                                  activity_from = dat$datetime1, 
                                  activity_to = dat$datetime2, 
                                  geometry = dat$geometry, prey_class = dat$prey, crs=3006)


# Clean data to make lines
obs_pnt<-rbind(dat_pnt[,c("rovbase_id", "geometry")],
               dod[,c("rovbase_id", "geometry")])

which.col=which.min(c(min(fam_groups$n.hclust), min(fam_groups$n.custom)))
which.method=c("h_clust", "custom")[which.col]
which.order=fam_groups$sorting[which.min(fam_groups[,(which.col+1)])]
reversed<-length(strsplit(which.order, "_")[[1]][1])==2
which.order<-strsplit(which.order, "_")[[1]][1]

my.grouped.obs<-grouplynx(RovbaseID = dat$rovbase_id, activity_from = dat$datetime1, activity_to =dat$datetime2, 
                       geometry = dat$geometry, prey_class = dat$prey, clust=which.method, 
                       which.order=which.order, reversed=reversed, pretty=F, crs=3006, save_geometry=T, 
                       path="Grouped/", obs_pnt = obs_pnt)

# Create leaflet for visualization
obs<-st_read("Grouped/FamilyGroupObservations_2025-12-08.gpkg")
my.cent<-st_read("Grouped/Groupings_2025-12-08.gpkg")
my.lines<-st_read("Grouped/GroupingsLines_2025-12-08.gpkg")

obs<-st_transform(obs, 4326)
my.cent<-st_transform(my.cent, 4326)
my.lines<-st_transform(my.lines, 4326)
dat_spor<-st_transform(dat_spor, 4326)

min.lat<-min(st_coordinates(obs)[,2])-0.005
max.lat<-max(st_coordinates(obs)[,2])+0.005
min.lon<-min(st_coordinates(obs)[,1])-0.005
max.lon<-max(st_coordinates(obs)[,1])+0.005

my.map<-leaflet() %>%
  addMeasure(primaryLengthUnit = "meters",
             primaryAreaUnit = "sqmeters") %>%
  fitBounds(lng1 = min.lon, lng2=max.lon, lat1 = min.lat, lat2=max.lat) %>%
  addProviderTiles(providers$OpenTopoMap) %>%
  addProviderTiles(
    "Esri.WorldImagery",
    group = "Esri.WorldImagery"
  ) %>%
  addScaleBar(position="bottomleft", options=scaleBarOptions(maxWidth=200)) %>%
  addCircleMarkers(color="red", 
                   opacity=1, fillOpacity=1,
                   labelOptions = labelOptions(noHide = F, direction = 'top', textOnly = T,
                                               style=list("font-size" = "20px")),
                   label= my.cent$groupID1,
                   radius=4,
                   data=my.cent) %>% 
  addCircleMarkers(color="black", 
                   opacity=2, fillOpacity=1,
                   labelOptions = labelOptions(noHide = F, direction = 'top', textOnly = T,
                                               style=list("font-size" = "20px")),
                   label= obs$RovbaseID,
                   radius=1,
                   data=obs) %>% 
  addPolylines(color="black", 
               opacity=1, fillOpacity=1,
               data= my.lines, weight=3) %>% 
  addPolylines(color="black", 
               opacity=1, fillOpacity=1,
               data=dat_spor, weight=0.5) %>% 
  addLayersControl(# position it on the topleft
    position = "topleft",
    overlayGroups = as.character(c(sort(unique(obs$RS)))),
    options = layersControlOptions(collapsed = T),
    baseGroups = c(
      "OpenTopoMap","Esri.WorldImagery"
    )
  ); my.map
plot(dat_spor$geometry)
saveWidget(my.map, file="Grouped/GroupedObs.html")