grouplynx<-function(RovbaseID, activity_from, activity_to, geometry, prey_class, clust, which.order, 
                    reversed, split=TRUE, pretty=TRUE, save_geometry=FALSE, path=NULL, hclust_poly=1, crs,
                    obs_pnts=NULL) {
  # obs_pnts are the points that are associated with every observation in Rovbase. 
  library(sf)
  library(plyr)
  library(dplyr)
  source("/home/rstudio/workspace/dump/Functions20251208/Functions/Function_CreateCenterpoints.R") 
  source("/home/rstudio/workspace/dump/Functions20251208/Functions/Function_CreateLines.R") 
  source("/home/rstudio/workspace/dump/Functions20251208/Functions/Function_CustomClustering.R") 
  source("/home/rstudio/workspace/dump/Functions20251208/Functions/Function_DistanceMatrix.R") 
  source("/home/rstudio/workspace/dump/Functions20251208/Functions/Function_TimeMatrix.R") 
  source("/home/rstudio/workspace/dump/Functions20251208/Functions/Function_DistanceRuleMatrix.R") 
  source("/home/rstudio/workspace/dump/Functions20251208/Functions/Function_HierarcichalClustering.R") 
  source("/home/rstudio/workspace/dump/Functions20251208/Functions/Function_Ordering.R") 
  source("/home/rstudio/workspace/dump/Functions20251208/Functions/Function_PrettyLines.R") 
  source("/home/rstudio/workspace/dump/Functions20251208/Functions/Function_SplitGroups.R") 
  source("/home/rstudio/workspace/dump/Functions20251208/Functions/Function_CreateOldDistanceRules.R") 
  
  if(!any(c("custom", "h_clust")%in%clust)){stop("The supplied clustering algorithm is not supported")}
  if(save_geometry==TRUE & length(path)==0){stop("Supply path to the shapefiles")}
  
  # ---- Create old distance rules
  dist.rules.all<-create_old_distance_rules()
  
  my.dat<-data.frame(RovbaseID=RovbaseID, activity_from=activity_from, activity_to=activity_to, prey_class=prey_class)
  my.dat<-st_as_sf(my.dat, geometry, crs)
  my.dat<-st_transform(my.dat, 32633)
  
  # Order the data, as the starting point has implications for how many observations we end up with
  my.dat<-this.order(data=my.dat, reversed = reversed, which.order = which.order)
  rownames( my.dat)<-1:nrow( my.dat)
  
  # ---- Create time matrix
  time.matrix<-create_time_matrix(activity_from = my.dat$activity_from, activity_to = my.dat$activity_to)
  
  # ---- Create distance matrix
  distm<-create_distance_matrix(geometry=my.dat$geometry)

  # ---- Create a distance rule matrix which reports distance rules for each pair of observations 
  # ---- based on the time matrix and the prey category
  dist.rule.mat<-create_distance_rule_matrix(time.matrix=time.matrix, prey_class=my.dat$prey_class, 
                                             dist.rules.all=dist.rules.all)
  
  # ---- Create a binary matrix indicating whether a pair of observations can be grouped together or not. 
  groupInd<-dist.rule.mat>distm
 
  # ----  Calculate a new matrix which is a relative index of over and under the distance rules. 
  # ----  This should have values over 1 for observations that should not be grouped and below 1 for observations that should be grouped
  groupingIndex<-distm/(dist.rule.mat)
  
  # ----  Hierarchical clustering
  if(clust=="h_clust"){
    my.dat$groupID1<-h_clust(groupingIndex=groupingIndex, hclust_poly = hclust_poly)
  }
  
  # ----  OR: customized clustering
  if(clust=="custom"){
    my.dat$groupID1<-custom_clustering(groupInd=groupInd)
  }
  
  # ----  Split the groupings and try alternative groupings to test if we can find fewer groups
  if(split){ 
    my.dat$groupID1<-split_groups(groupID1=my.dat$groupID1, groupInd=groupInd, distm=distm)
  } 
  
  # ----  Try to make prettier lines
  if(pretty){
    my.dat$groupID1<-pretty_lines(groupID1=my.dat$groupID1, distm=distm, groupInd=groupInd)
  } 
  
  # ----  Save the geometry?
  if(save_geometry){ # Saving output as shapefiles
    obs_pnt<-merge(obs_pnt, as.data.frame(my.dat[,c("RovbaseID", "groupID1")])[,1:2], 
                   by.x="rovbase_key_kilde", by.y="RovbaseID")
    
    my.dat_cent<-create_centerpoints(st_centroid(obs_pnt)) # Replaced old geometry with observation point
    
    my.dat_lines<-create_lines(my.dat=obs_pnt, my.dat_cent=my.dat_cent)
    
    # Export as shapefiles
    st_write(my.dat_cent, paste0(path, "Groupings_", Sys.Date(), ".gpkg"), append=FALSE)
    st_write(my.dat_lines, paste0(path, "GroupingsLines_", Sys.Date(), ".gpkg"), append=FALSE)
    st_write(obs_pnt, paste0(path, "FamilyGroupObservations_", Sys.Date(), ".gpkg"), append=FALSE)
  }
  
  # ----  Return the RovbaseID and grouping IDs
  return(data.frame(RovbaseID=my.dat$RovbaseID, groupID=my.dat$groupID1))
}


