# This script calculates the number of familiy groups in Norway

rm(list = ls()) # Clear workspace

# Load libraries
library(s2)
library(sf)
library(plyr)
library(dplyr)
library(tictoc)
# Sys.setlocale("LC_ALL", "nb-NO.UTF-8") # Set to Norwegian characters

# --------------------------------------------------------------------
# Source the functions used to calculate the number of family groups
# --------------------------------------------------------------------

# This first script contains the function "grouplynx()" this was the first to be written.
functions_path <- "/home/rstudio/workspace/dump/AutomatiskGruppering/Functions"


source(file.path(functions_path, "Function_GroupLynxOld.R"))
# grouplynx() needs the following arguments:
# RovbaseID: character with RovbaseID
# activity_from, time object as POSIXct. Define the activity period of the rovbase ID
# activity_to, time object as POSIXct. Define the activity period of the rovbase ID
# geomtery: the geometry of the RovbaseID, accepts points and lines. Needs to be on the sf format
# prey_class: the prey_class of the RovbaseID
# clust: either "custom" or "hclust". "custom" is an algorithm written based on the distance rules and hclust is hierciachal clustering
# ...... from base R. Both approaches should follow the rules of the distance rules but they can provide different answers.
# which.order: defines the starting point of the clustering (how should the data be ordered)
# reversed: TRUE/FALSE, should the order be reversed
# split_groups: TRUE/FALSE, should we run a second algorithm that goes through all groupings, split them and then put them back together
# ............. in an attempt to reduce the number of groups.
# pretty_lines: TRUE/FALSE. Should we try to assign the observations that can belong to multiple groups in a way that makes it look
# ............. nice on the map.
# save_shapefules: TRUE/FALSE, shall we save shapefiles of the clustering.
# path: pathway to where to store the shapefiles
# year: can be ignored
# hclust_poly: can be ignored

# The second script contains the function "this.order()"
functions_path <- "/home/rstudio/workspace/dump/AutomatiskGruppering/Functions"
source(file.path(functions_path, "Function_Ordering.R"))
# This function orders the data and are used inside grouplynx()

# The third script contain the function grouplynx_diff_starts().
source(file.path(functions_path, "Function_GroupLynxOld_MultipleStart.R"))
# This function tests several different starting points and use the same arguments as grouplynx(), with a few less options.
# The following needs to be define:
# RovbaseID, activity_from, activity_to, geometry, prey_class,q

data_path <- "/home/rstudio/workspace/dump/AutomatiskGruppering/Data"
dat.all <- readRDS(file.path(data_path, "Data2014_2021Compiled.rds"))
dat_2023 <- readRDS(file.path(data_path, "Data2023Compiled.rds"))

dat.all$l.length <- as.numeric(st_length(dat.all))

# To make it easier we do it only for Norway
dat.all <- dat.all[dat.all$country %in% "Norway" & dat.all$l.length < 10000, ]
# We also exclude observations that have really long tracks, these are obviosly wrong.
# an optimal solution for this would be to through a warning whenever someone are trying to upload really long
# tracks.

dat.all$datetime1 <- dat.all$`Aktivitetsdato fra`
dat.all$datetime2 <- dat.all$`Aktivitetsdato til`

# Pick one year
year <- 2020 # From 2014 to 2020
dat <- dat.all[dat.all$RS %in% year, ] # Sample data
View(dat)

# Prey classification
prey <- st_read(file.path(data_path, "byttedyrkategori_skandinavia_tettede_hull.shp"))
# plot(prey)

# Create an object containing the distance rules
dist.rules <- data.frame(
  prey = rep(c("High_biomass", "Low_biomass", "Southern_reindeer", "Northern_reindeer"), each = 11),
  days = rep(1:11, times = 4),
  dist1 = c(
    c(8, 12, 15, 16, 18, 19, 20, 20, 21, 21, 22), c(14, 20, 25, 28, 32, 33, 34, 35, 36, 39, 40),
    c(13, 18, 21, 24, 25, 27, 28, 29, 30, 30, 32), c(15, 22, 27, 31, 34, 36, 38, 39, 41, 42, 44)
  )
)

# Create an object which contains all possible combinations of prey classes
dist.rules.all <- expand.grid(
  prey1 = c("High_biomass", "Low_biomass", "Southern_reindeer", "Northern_reindeer"),
  prey2 = c("High_biomass", "Low_biomass", "Southern_reindeer", "Northern_reindeer"),
  days = 1:11,
  dist1 = NA
)

# Calculate the mean for unique combination across the different prey categories
for (i in 1:nrow(dist.rules.all)) {
  days <- dist.rules.all[i, ]$days
  prey1 <- dist.rules.all[i, ]$prey1
  prey2 <- dist.rules.all[i, ]$prey2
  dist.rules.all[i, ]$dist1 <- mean(c(
    dist.rules[dist.rules$days %in% days & dist.rules$prey %in% prey1, ]$dist1,
    dist.rules[dist.rules$days %in% days & dist.rules$prey %in% prey2, ]$dist1
  ))
}

###############################################################################################################
# Calculate distances between all observations and extract prey class
###############################################################################################################

# To-do list:
# 1. Run some geometry operations (like buffer or use administrative borders, not terrestrial) to make sure
#    all observations will be located in a prey class
# 2. How do we treat familygroups that have been tracked over the border between high and low prey density????


# First, order all observations by time
dat <- dat[order(dat$`Aktivitetsdato fra`), ]
rownames(dat) <- 1:nrow(dat)

# Extract prey classes
ind <- st_intersects(dat, st_buffer(prey, 2000))
any(lengths(ind) < 1)
table(lengths(ind) > 1)

dat$prey <- NA
dat[which(lengths(ind) == 1), ]$prey <- prey[unlist(ind[which(lengths(ind) == 1)]), ]$Kategori

for (ii in which(lengths(ind) > 1)) {
  dat[ii, ]$prey <- sample(x = prey[unlist(ind[which(lengths(ind) > 1)]), ]$Kategori, size = 1)
}

# This function takes 656 seconds to run on my laptop. This is because the distance calculations are calculated for each starting point.
# Definetely room for improvements on speed here, but I did not need them. I can improve the function if it is needed.
tic()
comp.df <- grouplynx_diff_starts(
  RovbaseID = dat$RovbaseID,
  activity_from = dat$datetime1,
  activity_to = dat$datetime2,
  geometry = dat$geometry, prey_class = dat$prey
)
# The warnings can be ignored.
toc()

# Lowest custom
min(comp.df$n.custom)
comp.df$sorting[which.min(comp.df$n.hclust)]
# Lowest hclust
min(comp.df$n.hclust)
comp.df$sorting[which.min(comp.df$n.custom)]


output_path <- "/home/rstudio/workspace/dump/AutomatiskGruppering/GroupedObsOld"

# Create a shapefile for the ordering and algorithm with the lowest number of family groups
tictoc::tic() # 15-30 secs
hclust_pca <- grouplynx(
  RovbaseID = dat$RovbaseID, activity_from = dat$datetime1, which.order = "pca1", reversed = T,
  activity_to = dat$datetime2, geometry = dat$geometry, prey_class = dat$prey, year = year,
  clust = "h_clust", save_shapefiles = TRUE, path = output_path, pretty_lines = T,
  hclust_poly = 1
)
tictoc::toc()
