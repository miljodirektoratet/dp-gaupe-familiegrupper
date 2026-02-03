# This function does the custom clusering
i=1
custom_clustering<-function(groupInd){
  groupID1<-rep(NA, times=dim(groupInd)[1])
  for(i in 1:dim(groupInd)[1]){
    if(!is.na(groupID1[i])){ # If it has already been assigned a group
      next
    }
    temp.group<-which(groupInd[i,])
    if(all(groupInd[temp.group, temp.group])){
      groupID1[temp.group]<-ifelse(suppressWarnings(max(groupID1, na.rm=TRUE))==-Inf, 1, suppressWarnings(max(groupID1, na.rm=TRUE))+1)
    } else{ # Remove one by until all is TRUE
      while(!all(groupInd[temp.group, temp.group])) {
        exclude.this<-which.max(apply(groupInd[temp.group, temp.group], 1, function(x){length(which(!x))})) # Excluding the one with most FALSE
        temp.group<-temp.group[-exclude.this]
      }
      groupID1[temp.group]<-ifelse(suppressWarnings(max(groupID1, na.rm=TRUE))==-Inf, 1, suppressWarnings(max(groupID1, na.rm=TRUE))+1)
    }
  }
  return(groupID1)
}
