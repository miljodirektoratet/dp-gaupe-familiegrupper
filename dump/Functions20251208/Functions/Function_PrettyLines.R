# This function creates pretty lines,
# People tend to complain about weird groupings, so this can probably be further developed

pretty_lines<-function(groupID1, distm, groupInd){
  criteria2<-data.frame(ind=1:length(groupID1), id=groupID1)
  while(!all(criteria2[,ncol(criteria2)]==criteria2[,ncol(criteria2)-1])){
    for(i in 1:length(groupID1)){
      # Which groups can it be assigned?
      this.groupID<-groupID1[i]
      temp.obs<-which(groupInd[i,])
      temp.groupIDs<-unique(groupID1[temp.obs])

      if(length(temp.groupIDs)==1){ # Go to next if it only can be grouped to that grouping
        next
      }

      # Inspect if alternative groups can take the new observation
      alt.groups<-vector()
      for(j in temp.groupIDs){
        ind<-as.numeric(which(groupID1%in%j))
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
        this.indW<-unique(c(as.numeric(which(groupID1%in%j)),i)) # Adding the obs to make sure it is included for all groups
        temp.matW<-distm[this.indW,this.indW]
        temp.matW[upper.tri(temp.matW)] <- 0
        alt.groups.df[alt.groups.df$groupID1%in%j,]$distW<-sum(temp.matW)

        # Without the observation
        this.indWO<-this.indW[which(!this.indW%in%i)]
        temp.matWO<-distm[this.indWO,this.indWO]
        temp.matWO[upper.tri(temp.matWO)] <- 0
        alt.groups.df[alt.groups.df$groupID1%in%j,]$distWO<-sum(temp.matWO)
      }

      alt.groups.df$criteria<-NA # Calculating the criterion; sum of all internal distances for the involved groupings when the observation is added to the given group
      for(j in 1:nrow(alt.groups.df)){
        alt.groups.df[j,]$criteria<-alt.groups.df[j,]$distW+sum(alt.groups.df[which(!1:nrow(alt.groups.df)%in%j),]$distWO)
      }

      # Assign the observation the groupID which minimized the sum of all internal distances
      groupID1[i]<-alt.groups.df[which.min(alt.groups.df$criteria),]$groupID1
    } # End first. for loop
    criteria2[,ncol(criteria2)+1]<-groupID1
  }
  return(groupID1)
}
# Search through all observations and assign the observation to the grouping with shortest distance, do it untill nothing changes
