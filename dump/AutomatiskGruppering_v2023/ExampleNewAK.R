# This script tests the group lynx function

rm(list=ls())

# Load function
#library(s2)
library(sf)
#library(plyr)
library(dplyr)
#library(gdistance)
library(parallel)
#library(terra)

# The naming of the functions are the same as in the example with the old distance rules (should have been changed)
# They take slightly different arguments and they should be more efficient.
source("Functions/Function_GroupLynxNew.R")
source("Functions/Function_GroupLynxNew_MultipleStart.R")
source("Functions/Function_Ordering.R")

##########################################################################################################################
# Calculate distance for not crossing the ocean - ####### DO NOT RUN
##########################################################################################################################

#WARNING!!!
# The efficiency of the distance calculations needs to be improved before this is implemented in Rovbase!
# There is multiple ways of doing that:
# 1. store the distances that are already calculated and only add new ones.
# 2. explore if there is any efficiency improvement in restricting the search radius with a buffer. The buffer needs to longer
#    than the longest distance in the distance rules. I do not believe there is too much to gain in creating a search radius.

# Import lynx observations
data_path <- "/home/rstudio/workspace/dump/AutomatiskGruppering/Data"
dat <- readRDS(file.path(data_path, "Data2023Compiled.rds"))

# Import transition matrix to calculate distances on
#tr_cost<-readRDS("Data/LandUtenHav250_TransitionLayer1s.rds") # You might need to load this on a server and not locally

# Import a raster with cells where there is no ocean
# land<-rast("Data/LandUtenHav250.tif")

# Cast the data as multipoint, these means the "sporlogger" will have multiple points per "sporlogg"
dat.p<-st_cast(st_cast(dat, "MULTIPOINT"), "POINT")

# Check if some of the observations are made in the ocean
# res<-terra::extract(x=land, y=dat.p, cells=T)

# Sample a neighbouring cell if a an observations is located in water
for(i in which(res$val%in%0)){
  neig<-adjacent(land, cells=res[i,]$cell, directions=8)
  which_on_land<-terra::extract(x=land, y=as.vector(neig))
  which_on_land<-which_on_land$val%in%1
  res[i,]$cell<-sample(neig[which_on_land], size=1)
}

# Extract the coordinates
dat.p$cell_nr<-res$cell
dat.p<-unique(as.data.frame(dat.p[,c("RovbaseID", "cell_nr")])[,1:2])
dat.p[,c("X","Y")]<-xyFromCell(land, dat.p$cell_nr)

dat.p<-dat.p[order(dat.p$RovbaseID),]
rownames(dat.p)<-1:nrow(dat.p)

#saveRDS(dat.p, "Data/IdentifierDistances.rds")
tictoc::tic()
# ENDRE; hvorfor ikke bare bruke parDist?
out<-mclapply(1:nrow(dat.p), mc.cores=3, function(x){
  A <- sp::SpatialPoints(dat.p[x,c("X","Y")])
  Bs <- sp::SpatialPoints(dat.p[,c("X","Y")])
  AtoBs <- st_as_sf(shortestPath(tr_cost, A, Bs, output="SpatialLines"))
  return(st_length(AtoBs))
})
tictoc::toc()

dist.mat.extended<-do.call("cbind", out)

#saveRDS(dist.mat.extended, "Data/Distmat.rds")

##########################################################################################################################
############## END - DO NOT RUN
##########################################################################################################################


# Import lynx observations
dat<-readRDS("Data/Data2023Compiled.rds")

dist.mat.extended<-readRDS("Data/Distmat.rds")
dat.p<-readRDS("Data/IdentifierDistances.rds")

i="R556094"
j="R556726"
# Now we need to aggregate the distance matrix to observations. The extended distance matrix can have multiple distances per observation
distm<-matrix(NA, nrow=length(unique(dat$RovbaseID)), ncol=length(unique(dat$RovbaseID)))
rovbaseIDs<-unique(dat.p$RovbaseID)
for(i in rovbaseIDs){
  ind_i<-rownames(dat.p[dat.p$RovbaseID%in%i,])
  nr_i<-which(rovbaseIDs%in%i)
  for(j in rovbaseIDs){
    ind_j<-rownames(dat.p[dat.p$RovbaseID%in%j,])
    nr_j<-which(rovbaseIDs%in%j)

    distm[nr_i,nr_j]<-max(dist.mat.extended[as.numeric(ind_i), as.numeric(ind_j)])
  }
}

# R555181 is wrong, there is a track that is not valid included there
# R559946 is also wrong, but not that much
# Issues like these should ideally be picked up through quality control


x=vector()
for(i in 1:385){
  x[i]<-distm[i,i]
}
x[170]<-0
x[380]<-0
rovbaseIDs[which.max(x)]

for(i in 1:385){
  distm[i,i]<-0
}


# Reorder, so the order in the data are the same
reorder.df<-data.frame(RovbaseID=rovbaseIDs, distm_order=1:length(rovbaseIDs))
dat$dat_order<-1:nrow(dat)

reorder.df<-merge(reorder.df, as.data.frame(dat[,c("RovbaseID", "dat_order")])[,1:2], by="RovbaseID", all.x=T)

distm<-distm[reorder.df[order(reorder.df$dat_order),]$distm_order,reorder.df[order(reorder.df$dat_order),]$distm_order]

distm[which(dat$RovbaseID%in%c("R554741", "R554708", "R555949", "R553848", "R555095")),
      which(dat$RovbaseID%in%c("R554741", "R554708", "R555949", "R553848", "R555095"))]


# Extract prey
deer<-rast("Data/DeerTerrestrial.tif")
dat$prey<-terra::extract(x=deer, y=vect(st_centroid(dat)))[,2]
dat$prey<-log(dat$prey+0.0001)
range(dat$prey)

# Calculate the number of family groups with multiple starting points.
# This function is improved, as the distance calculation is conducted only once (outside the function)
# it takes 229 seconds compared to 656 seconds with the old distance rules
tictoc::tic()
comp.df<-grouplynx_new_diff_starts(RovbaseID = dat$RovbaseID, distm=distm,
                               activity_from = dat$datetime1,
                               activity_to = dat$datetime2,
                               geometry = dat$geometry, prey_class = dat$prey)
tictoc::toc()

# Lowest custom
min(comp.df$n.custom)
comp.df$sorting[which.min(comp.df$n.hclust)]
# Lowest hclust
min(comp.df$n.hclust)
comp.df$sorting[which.min(comp.df$n.custom)]

# Create a shapefile for the ordering and algorithm with the lowest number of family groups
tictoc::tic() # 25-35 secs
hclust_pca<-grouplynx_new(RovbaseID = dat$RovbaseID, distm=distm, activity_from = dat$datetime1, which.order="north", reversed=F,
                      activity_to = dat$datetime2,geometry = dat$geometry, prey_class = dat$prey, year=2024,
                      clust="h_clust", save_shapefiles = TRUE, path="GroupedObsNew/", pretty_lines = T,
                      hclust_poly=1)
tictoc::toc()
