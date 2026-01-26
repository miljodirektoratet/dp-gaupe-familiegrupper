# This function creates distance rules for all possible combinations based on the old rules

create_old_distance_rules<-function(){
  # Create the distance rules
  dist.rules<-data.frame(prey=rep(c("High_biomass", "Low_biomass", "Southern_reindeer", "Northern_reindeer"), each=11),
                         days=rep(1:11, times=4),
                         dist1=c(c(8,12,15,16,18,19,20,20,21,21,22), c(14,20,25,28,32,33,34,35,36,39,40),
                                 c(13,18,21,24,25,27,28,29,30,30,32), c(15,22,27,31,34,36,38,39,41,42,44)))


  # Create an object which contains all possible combinations of prey classes
  dist.rules.all<-expand.grid(prey1=c("High_biomass", "Low_biomass", "Southern_reindeer", "Northern_reindeer"),
                              prey2=c("High_biomass", "Low_biomass", "Southern_reindeer", "Northern_reindeer"),
                              days=1:11,
                              dist1=NA)


  # Calculate the distance rules for all possible combinations, this is the one that will be used later
  for(i in 1:nrow(dist.rules.all)){
    days<-dist.rules.all[i,]$days
    prey1<-dist.rules.all[i,]$prey1
    prey2<-dist.rules.all[i,]$prey2
    dist.rules.all[i,]$dist1<-mean(c(dist.rules[dist.rules$days%in%days & dist.rules$prey%in%prey1,]$dist1,
                                     dist.rules[dist.rules$days%in%days & dist.rules$prey%in%prey2,]$dist1))
  }
  dist.rules.all$dist1<-dist.rules.all$dist1*1000
  return(dist.rules.all)
}
