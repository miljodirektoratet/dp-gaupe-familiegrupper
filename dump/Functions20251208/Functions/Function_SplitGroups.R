# This function splits groups and try to relocate the observation to new grouping to reduce the number of
# family groups

# Search through all groupings and see if some can be split, do it as many times as we are getting a reduction in the number of groups
i=4
split_groups<-function(groupID1, groupInd, distm){
  criteria1<-data.frame(col1=Inf, col2=length(unique(groupID1)))
  while(!criteria1[,ncol(criteria1)]==criteria1[,ncol(criteria1)-1]){
    for(i in unique(groupID1)){
      row.nr<-as.numeric(which(groupID1%in%i))

      # Own pathway for single obs groups
      # Can it potentially be given away an to which groups
      if(length(row.nr)==1){ # Start single obs path
        if(any(groupInd[row.nr,which(!(1:length(groupID1)%in%row.nr))])){
          temp<-data.frame(ind=row.nr, currentID=i, altID=unique(groupID1[groupInd[row.nr,which(!(1:length(groupID1)%in%row.nr))]]))
          altern.obs<-NULL
        } else {
          next
        } # End single obs path
      } else { # Start mutliple rows
        # Can all be given away?
        give.away.mat<-groupInd[row.nr,which(!(1:length(groupID1)%in%row.nr))]
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
            temp<-rbind(temp, data.frame(ind=row.nr[j], currentID=i, altID=unique(groupID1[altern.obs[[j]]])))
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
        ind.this.group<-as.numeric(which(groupID1%in%temp[j,]$altID)) # Indices for the alternative group
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
              this.indW<-unique(c(as.numeric(which(groupID1%in%alt.groups.df[k,]$ID)),alt.groups.df[k,]$ind)) # Adding the obs to make sure it is included for all groups
              temp.matW<-distm[this.indW,this.indW]
              temp.matW[upper.tri(temp.matW)] <- 0
              alt.groups.df[k,]$distW<-sum(temp.matW)

              # Without the observation
              this.indWO<-this.indW[which(!this.indW%in%alt.groups.df[k,]$ind)]
              temp.matWO<-distm[this.indWO,this.indWO]
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
        groupID1[temp$ind]<-temp$altID
      }
    }
    criteria1[1,ncol(criteria1)+1]<-length(unique(groupID1))
  }
  return(groupID1)
}
