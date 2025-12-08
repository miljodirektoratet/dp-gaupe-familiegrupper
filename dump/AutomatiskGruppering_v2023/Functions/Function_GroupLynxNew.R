# This scripts contains the function to group observations of lynx into family groups based on the distance rules derived in Gervasi et al. 2013
source("Functions/Function_Ordering.R")
grouplynx_new<-function(RovbaseID, distm, geometry, activity_from, activity_to, prey_class, clust, which.order, reversed,
                    split_groups=TRUE, pretty_lines=TRUE, save_shapefiles=FALSE, path=NULL, year,
                    hclust_poly=1) {
  library(sf)
  library(plyr)
  library(dplyr)

  if(!any(c("custom", "h_clust")%in%clust)){stop("The supplied clustering algorithm is not supported")}

  if(save_shapefiles==TRUE & length(path)==0){stop("Supply path to the shapefiles")}

  # Create the distance rules
#  dist.rules<-data.frame(days=0:14,
#                         intercept=c(7.593146, 10.269125, 12.875547, 15.235871, 16.159384, 17.098220, 17.940282, 18.266881, 18.437078,
#                                     18.461328, 18.542999, 18.782211, 18.980102, 19.022797, 20.871274),
#                         k=c(0.04558200, 0.05230647, 0.05703082, 0.05822413, 0.05984182, 0.06315650, 0.06369901, 0.06735619, 0.06869668,
#                             0.07173490, 0.07387917, 0.07483155, 0.07808518, 0.07891145, 0.07896910))


  my.dat<-data.frame(RovbaseID=RovbaseID, activity_from=activity_from, activity_to=activity_to, prey_class=prey_class)
  my.dat<-st_as_sf(my.dat, geometry, crs=32633)

  # Set the ordering and calculate the distance matrix
  my.dat$original_order<-as.numeric(rownames(my.dat))
  my.dat<-this.order(data=my.dat, reversed = reversed, which.order = which.order)
  my.dat$new_order<-as.numeric(rownames(my.dat))

  # HERE WE NEED TO REORDER DISTM
  dimnames(distm)<-list(c(1:dim(distm)[1]), c(1:dim(distm)[1]))
  distm2<-distm[my.dat[order(my.dat$new_order),]$original_order,my.dat[order(my.dat$new_order),]$original_order]

  if(isSymmetric(distm2)==FALSE) {stop('Distance matrix is not symmetrical, supply a symmetric distance matrix')}

  # ---- The time matrix needs to be revisited
  # Setting up at time array to find which observations cannot be grouped together based on the dynamic rule
  time.array<-array(data = c(abs(outer(my.dat$activity_from, my.dat$activity_from, difftime, units="days"))+0.001,
                             abs(outer(my.dat$activity_from, my.dat$activity_to, difftime, units="days"))+0.001,
                             abs(outer(my.dat$activity_to, my.dat$activity_from, difftime, units="days"))+0.001,
                             abs(outer(my.dat$activity_to, my.dat$activity_to, difftime, units="days"))+0.001),
                    dim=c(nrow(my.dat), nrow(my.dat), 3))
  time.matrix<-apply(time.array, c(1,2), function(x){max(x, na.rm = TRUE)})
  time.matrix<-ceiling(time.matrix) # Think through if this approach fix the time isse

  if(any(is.na(time.matrix))) {stop('Time array contains NA, make sure that there are no NAs in the time columns')}
  if(isSymmetric(time.matrix)==FALSE) {stop('Time array is not symmetrical, contact Neri Horntvedt Thorsen')}

  # Create a distance rule matrix which reports distance rules for each pair of observations based on the time matrix and the prey category
  dist.rule.mat<-time.matrix
  # ENDRE: WHY HARD CODE THIS EDIT?
  dist.rule.mat[dist.rule.mat>10]<-10

  pred_eq<-function(diff.days, deer){diff.days*1048.841 + diff.days*deer*(-338.458)+10865.956}

  for(i in 1:dim(dist.rule.mat)[1]){
    prey1<-my.dat[i,]$prey_class
    prey2<-my.dat$prey_class
    days<-dist.rule.mat[i,]
    dist1<-unlist(lapply(1:nrow(my.dat), function(x){
      pred_eq(diff.days=days[x], deer=mean(c(prey1,prey2[x])))}))
    dist.rule.mat[i,]<-dist1
  }

  diag(dist.rule.mat)<-Inf # Setting the diagonal to Inf as an observations should be grouped with it self
  if(any(is.na(dist.rule.mat))) {stop('Distance rule matrix contains NA, contact Neri Horntvedt Thorsen')}
  if(isSymmetric(dist.rule.mat)==FALSE) {stop('Distance rule matrix is not symmetrical, contact Neri Horntvedt Thorsen')}

  # Creating a binary matrix indicating whether a pair of observations can be grouped together or not.
  groupInd<-dist.rule.mat>distm2
  if(any(is.na(groupInd))) {stop("NAs in the grouping index matrix")}
  if(isSymmetric(groupInd)==FALSE) {stop("Grouping index matrix is not symmetrical")}

  # Calculate a new matrix which is a relative index of over and under the distance rules.
  # This should have values over 1 for observations that should not be grouped and below 1 for observations that should be grouped

  groupingIndex<-distm2/(dist.rule.mat)
  isSymmetric(groupingIndex)

  # Which clustering should be used, h_clust or custom
  if(clust=="h_clust"){
    # Run the clustering
    my.clust<-hclust(as.dist(groupingIndex^hclust_poly))

    # Cluster at height 1
    my.dat$groupID1<-cutree(my.clust, h=1)
  }

  if(clust=="custom"){
    my.dat$groupID1<-NA
    for(i in 1:nrow(my.dat)){
      if(!is.na(my.dat[i,]$groupID1)){ # If it has already been assigned a group
        next
      }
      temp.group<-which(groupInd[i,])
      if(all(groupInd[temp.group, temp.group])){
        temp.group[which(is.na(my.dat[temp.group,]$groupID1))]
        my.dat[temp.group,]$groupID1<-ifelse(max(my.dat$groupID1, na.rm=TRUE)==-Inf, 1, max(my.dat$groupID1, na.rm=TRUE)+1)
        #    my.dat[temp.group[which(is.na(my.dat[temp.group,]$groupID1))],]$groupID1<-ifelse(max(my.dat$groupID1, na.rm=TRUE)==-Inf, 1, max(my.dat$groupID1, na.rm=TRUE)+1)
      } else{ # Remove one by until all is TRUE
        while(!all(groupInd[temp.group, temp.group])) {
          exclude.this<-which.max(apply(groupInd[temp.group, temp.group], 1, function(x){length(which(!x))})) # Excluding the one with most FALSE
          temp.group<-temp.group[-exclude.this]
        }
        my.dat[temp.group,]$groupID1<-ifelse(max(my.dat$groupID1, na.rm=TRUE)==-Inf, 1, max(my.dat$groupID1, na.rm=TRUE)+1)
        #    my.dat[temp.group[which(is.na(my.dat[temp.group,]$groupID1))],]$groupID1<-ifelse(max(my.dat$groupID1, na.rm=TRUE)==-Inf, 1, max(my.dat$groupID1, na.rm=TRUE)+1)
      }

    }
  }

  if(split_groups){ # Start split groups
    # Search through all groupings and see if some can be split, do it as many times as we are getting a reduction in the number of groups
    criteria1<-data.frame(col1=Inf, col2=length(unique(my.dat$groupID1)))
    while(!criteria1[,ncol(criteria1)]==criteria1[,ncol(criteria1)-1]){
      for(i in unique(my.dat$groupID1)){
        row.nr<-as.numeric(rownames(my.dat[my.dat$groupID1%in%i,]))

        # Own pathway for single obs groups
        # Can it potentially be given away an to which groups
        if(length(row.nr)==1){ # Start single obs path
          if(any(groupInd[row.nr,which(!(1:nrow(my.dat)%in%row.nr))])){
            temp<-data.frame(ind=row.nr, currentID=i, altID=unique(my.dat[groupInd[row.nr,which(!(1:nrow(my.dat)%in%row.nr))],]$groupID1))
            altern.obs<-NULL
          } else {
            next
          } # End single obs path
        } else { # Start mutliple rows
          # Can all be given away?
          give.away.mat<-groupInd[row.nr,which(!(1:nrow(my.dat)%in%row.nr))]
          if(length(dim(give.away.mat))==0 & !all(give.away.mat)){
            next # If only vector and not all can be given away
          }
          if(!all(apply(give.away.mat, 1, function(x){any(x)}))){
            next # If not go to next
          }

          # To which groups
          altern.obs<-apply(groupInd[row.nr,], 1, function(x){which(x)}) # Observations they can be grouped together with
          temp<-data.frame(ind=NA, currentID=NA, altID=NA)[-1,] # Relation between observation, groupID and alternative group
          for(j in 1:length(row.nr)){
            if(length(altern.obs[[j]])>0){
              temp<-rbind(temp, data.frame(ind=row.nr[j], currentID=i, altID=unique(my.dat[altern.obs[[j]],]$groupID1)))
            } else {
              temp<-rbind(temp, data.frame(ind=row.nr[j], currentID=i, altID=NA))
            }
          }
        } # End multiple rows

        # Excluding those with currentID equals the alternative ID
        temp<-temp[!temp$currentID==temp$altID,]
        if(nrow(temp)==0){
          next # Go to next if temp has no rows == cant be given away
        }

        # Can the group accept the new observation(s)?
        temp$accept<-NA
        for(j in 1:nrow(temp)){
          ind.this.group<-as.numeric(rownames(my.dat[my.dat$groupID1%in%temp[j,]$altID,])) # Indices for the alternative group
          temp[j,]$accept<-all(groupInd[temp[j,]$ind, ind.this.group])
        }
        accepted<-unique(temp[,c("ind", "currentID")])
        accepted$accept<-ifelse(accepted$ind%in%temp[temp$accept,]$ind, TRUE, FALSE)

        if(all(accepted$accept) & all(row.nr%in%accepted$ind)){
          temp<-unique(temp[temp$accept,c("ind", "currentID", "altID", "accept")])
          for(j in unique(temp$ind)){
            if(nrow(temp[temp$ind%in%j,])>1){
              # Finding which group we should group it to

              # Calculate the internal distance with and without the observation
              alt.groups.df<-data.frame(ind=temp[temp$ind%in%j,]$ind, ID=temp[temp$ind%in%j,]$altID, distW=NA, distWO=NA)
              for(k in 1:nrow(alt.groups.df)){
                # With the observation
                this.indW<-unique(c(as.numeric(rownames(my.dat[my.dat$groupID1%in%alt.groups.df[k,]$ID,])),alt.groups.df[k,]$ind)) # Adding the obs to make sure it is included for all groups
                temp.matW<-distm2[this.indW,this.indW]
                temp.matW[upper.tri(temp.matW)] <- 0
                alt.groups.df[k,]$distW<-sum(temp.matW)

                # Without the observation
                this.indWO<-this.indW[which(!this.indW%in%alt.groups.df[k,]$ind)]
                temp.matWO<-distm2[this.indWO,this.indWO]
                temp.matWO[upper.tri(temp.matWO)] <- 0
                alt.groups.df[k,]$distWO<-sum(temp.matWO)
              }

              alt.groups.df$criteria<-NA # Calculating the criterion; sum of all internal distances for the involved groupings when the observation is added to the given group
              for(k in 1:nrow(alt.groups.df)){
                alt.groups.df[k,]$criteria<-alt.groups.df[k,]$distW+sum(alt.groups.df[which(!1:nrow(alt.groups.df)%in%k),]$distWO)
              }
              temp<-temp[!(temp$ind%in%alt.groups.df$ind & temp$altID%in%alt.groups.df[which.min(alt.groups.df$criteria),]$ID),]
            }
          }
          my.dat[temp$ind,]$groupID1<-temp$altID
        }
      }
      criteria1[1,ncol(criteria1)+1]<-length(unique(my.dat$groupID1))
    }
  } # End split groups

  if(pretty_lines){ # Start pretty lines
    # Search through all observations and assign the observation to the grouping with shortest distance, do it untill nothing changes
    criteria2<-data.frame(ind=1:nrow(my.dat), id=my.dat$groupID1)
    while(!all(criteria2[,ncol(criteria2)]==criteria2[,ncol(criteria2)-1])){
      for(i in 1:nrow(my.dat)){
        # Which groups can it be assigned?
        this.groupID<-my.dat[i,]$groupID1
        temp.obs<-which(groupInd[i,])
        temp.groupIDs<-unique(my.dat[temp.obs,]$groupID1)

        if(length(temp.groupIDs)==1){ # Go to next if it only can be grouped to that grouping
          next
        }

        # Inspect if alternative groups can take the new observation
        alt.groups<-vector()
        for(j in temp.groupIDs){
          ind<-as.numeric(rownames(my.dat[my.dat$groupID1%in%j,]))
          # Can the group take the new observation
          if(all(groupInd[i,ind])){
            alt.groups<-c(j,alt.groups)
          }
        }

        if(length(alt.groups)<1.1){ # Go to next if the alternative group cannot take the new observation (this might change in later runs)
          next
        }

        # Create a data.frame to store the sum of the internal distances with and without the observation
        alt.groups.df<-data.frame(groupID1=alt.groups, distW=NA, distWO=NA)
        for(j in alt.groups){
          # With the observation
          this.indW<-unique(c(as.numeric(rownames(my.dat[my.dat$groupID1%in%j,])),i)) # Adding the obs to make sure it is included for all groups
          temp.matW<-distm2[this.indW,this.indW]
          temp.matW[upper.tri(temp.matW)] <- 0
          alt.groups.df[alt.groups.df$groupID1%in%j,]$distW<-sum(temp.matW)

          # Without the observation
          this.indWO<-this.indW[which(!this.indW%in%i)]
          temp.matWO<-distm2[this.indWO,this.indWO]
          temp.matWO[upper.tri(temp.matWO)] <- 0
          alt.groups.df[alt.groups.df$groupID1%in%j,]$distWO<-sum(temp.matWO)
        }

        alt.groups.df$criteria<-NA # Calculating the criterion; sum of all internal distances for the involved groupings when the observation is added to the given group
        for(j in 1:nrow(alt.groups.df)){
          alt.groups.df[j,]$criteria<-alt.groups.df[j,]$distW+sum(alt.groups.df[which(!1:nrow(alt.groups.df)%in%j),]$distWO)
        }

        # Assign the observation the groupID which minimized the sum of all internal distances
        my.dat[i,]$groupID1<-alt.groups.df[which.min(alt.groups.df$criteria),]$groupID1
      } # End first. for loop
      criteria2[,ncol(criteria2)+1]<-my.dat$groupID1
    }
  } # End pretty_lines

  if(save_shapefiles){ # Saving output as shapefiles
    # Extract coordinates to be able to create sentre points
    my.dat$X33<-st_coordinates(st_centroid(my.dat))[,1]
    my.dat$Y33<-st_coordinates(st_centroid(my.dat))[,2]

    # Making centre points for the groupings
    my.dat_cent<-ddply(as.data.frame(my.dat), .(groupID1), summarise,
                       cent_X33=mean(X33),
                       cent_Y33=mean(Y33))

    # Importing centre coordinates to observations
    my.dat<-merge(my.dat, my.dat_cent, by="groupID1")

    # Make the centroid spatial
    my.dat_cent<-st_as_sf(my.dat_cent,
                          coords = c("cent_X33", "cent_Y33"), crs = 32633)

    # Making line from observation to center point
    my.dat_lines<-as.data.frame(my.dat[!is.na(my.dat$cent_Y33),])
    rownames(my.dat_lines)<-1:nrow(my.dat_lines)
    ls <- lapply(1:nrow(my.dat_lines), function(x)
    {
      v <- as.numeric(my.dat_lines[x,c("cent_X33", "cent_Y33", "X33", "Y33")])
      m <- matrix(v, nrow = 2, byrow=TRUE)
      return(st_sfc(st_linestring(m), crs = 32633))
    })

    ls = Reduce(c, ls)
    my.dat_lines<-st_sf(ls)
    my.dat_lines$RovbaseID <- my.dat[!is.na(my.dat$cent_Y33),]$RovbaseID
    my.dat_lines$RS <- my.dat[!is.na(my.dat$cent_Y33),]$RS

    # Export as shapefiles
    st_write(my.dat_cent, paste0(path, "Groupings_", year, ".shp"), append=FALSE)
    st_write(my.dat_lines, paste0(path, "GroupingsLines_", year, ".shp"), append=FALSE)
    st_write(st_centroid(my.dat), paste0(path, "FamilyGroupObservations_", year, ".shp"), append=FALSE)
  }
  return(data.frame(RovbaseID=my.dat$RovbaseID, groupID=my.dat$groupID1))
}




# I hashtag the following lines: 305-349, 2023.11.17
# my.dat$groupID1<-NA
#
# n.pos<-apply(groupInd, 1, function(x){length(which(x))})
# # First group all observations that only can be grouped with itself or with another group of observations that only can be
# # grouped with each other.
# for(j in 1:nrow(my.dat)){
#   if(is.na(my.dat[j,]$groupID1)){ # If the observations has not been given an ID already
#     group<-which(groupInd[j,])
#     if(all(groupInd[group, group])){ # If all can be grouped together
#       if(all(n.pos[group]==length(group))){ # If there is no other observation it can be grouped together with
#         my.dat[group,]$groupID1<-ifelse(any(!is.na(my.dat$groupID1)), max(my.dat$groupID1, na.rm=TRUE)+1,1)
#       }
#     }
#   }
# }
#
# # Second, group all observations where all observations have within 1 more or less possible observations to be grouped with
# # Oncly include observations with equal amount of possible observations to be grouped with.
# for(j in 1:nrow(my.dat)){
#   if(is.na(my.dat[j,]$groupID1)){ # If the observations has not been given an ID already
#     group<-which(groupInd[j,])
#     if(all(groupInd[group, group])){ # If all can be grouped together
#       if(all(n.pos[group]>=(length(group)-1) & n.pos[group]<=(length(group)+1)) & all(is.na(my.dat[group,]$groupID1))){ # If there is no other observation it can be grouped together with
#         include.in.group<-which(n.pos[group]>=(length(group)-1) & n.pos[group]<=(length(group)+1))
#         my.dat[group[include.in.group],]$groupID1<-ifelse(any(!is.na(my.dat$groupID1)), max(my.dat$groupID1, na.rm=TRUE)+1,1)
#       }
#     }
#   }
# }
#
# # Third, identify all observations that can be grouped with another set of observations, but the set of observations
# # more observations which they can be grouped with
# # Assign the given observation an ID
# for(x in 2:10){
#   for(j in 1:nrow(my.dat)){
#     if(is.na(my.dat[j,]$groupID1)){ # If the observations has not been given an ID already
#       group<-which(groupInd[j,])
#       if(n.pos[j]<x){
#         if(all(is.na(my.dat[group,]$groupID1))){
#           my.dat[j,]$groupID1<-ifelse(any(!is.na(my.dat$groupID1)), max(my.dat$groupID1, na.rm=TRUE)+1,1)
#         }
#       }
#     }
#   }
# }











#
# n.pos.groups<-unlist(lapply(1:nrow(my.dat), function(x){length(unique(na.omit(my.dat[which(groupInd[x,]),]$groupID1)))}))
#
# temp<-my.dat[which(n.pos.groups==0),]
# my.clust<-hclust(as.dist(groupingIndex[which(n.pos.groups==0),which(n.pos.groups==0)]))
# temp$groupID1<-cutree(my.clust, h=1)
# my.dat[which(n.pos.groups==0),]$groupID1<-max(my.dat$groupID1, na.rm=TRUE)+temp$groupID1
#
# # Perhaps try to split these groups
# n.pos.groups2<-unlist(lapply(1:nrow(my.dat), function(x){length(unique(na.omit(my.dat[which(groupInd[x,]),]$groupID1)))}))
#
#
# # implement this one into the algorithm, to be cut at different heights
#
# # Cluster at height
# table(temp$groupID1)
# table(my.dat$groupID1)
# # Fourth, assign the rest of the observations to one of the groups already identified
# for(i in 1:nrow(my.dat)){
#   if(is.na(my.dat[i,]$groupID1)){
#     n.pos[i]
#   }
# }
#
#
#
# i=2
# j=13
# for(i in 2:max(n.pos)){
#   new.ind<-which(n.pos==i)
#   for(j in new.ind){
#     if(!is.na(my.dat[j,]$groupID1)){
#       next
#     }
#     group<-which(groupInd[j,])
#
#   }
# }
#
#
# # Ny tankegang, fortsett med en algoritme så lenge det finnes observasjoner som ikke kan knyttes til en ikke allerede navngitt
# # gruppering. Dette vil gi problemer med at de gjenværende punktene ikke all kan knyttes til de samme gruppene.
# group
# my.dat[my.dat$n.pos%in%2 & is.na(my.dat$groupID1),]
#
# table(n.pos)
# table(my.dat[is.na(my.dat$groupID1),]$n.pos)
# table(is.na(my.dat$groupID1))
# table(my.dat$groupID1)
#
# plot(my.dat$geometry)
# plot(my.dat[!is.na(my.dat$groupID1),]$geometry, add=TRUE, col="red")
#
#
#
#
#
#
# my.clust<-hclust(as.dist(groupingIndex^hclust_poly))
#
# # implement this one into the algorithm, to be cut at different heights
#
# # Cluster at height
# my.dat$groupID1<-cutree(my.clust, h=2)
# table(my.dat$groupID1)
# length(unique(my.dat$groupID1))
# i=2
# for(i in unique(my.dat$groupID1)){
#   row.nr<-as.numeric(rownames(my.dat[my.dat$groupID1%in%i,]))
#   if(all(groupInd[row.nr, row.nr])){
#     next
#   }
#   temp<-my.dat[row.nr,]
#   my.clust.temp<-hclust(as.dist(groupingIndex[row.nr,row.nr]^hclust_poly))
#   temp$groupID1<-cutree(my.clust.temp, h=1)
#   temp$groupID1<-max(my.dat$groupID1, na.rm=TRUE)+temp$groupID1
#   my.dat[row.nr,]$groupID1<-temp$groupID1
# }
