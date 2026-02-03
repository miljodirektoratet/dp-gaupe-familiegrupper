# This script creates a distance rule matrix

create_distance_rule_matrix<-function(time.matrix, prey_class, dist.rules.all){
  dist.rule.mat<-time.matrix
  dist.rule.mat[dist.rule.mat>11]<-11

  for(i in 1:dim(dist.rule.mat)[1]){
    prey1<-prey_class[i]
    prey2<-prey_class
    days<-dist.rule.mat[i,]
    dist1<-unlist(lapply(1:length(prey_class), function(x){
      dist.rules.all[dist.rules.all$prey1%in%prey1 & dist.rules.all$prey2%in%prey2[x]
                     & dist.rules.all$days%in%days[x],]$dist1}))
    dist.rule.mat[i,]<-dist1
  }

  diag(dist.rule.mat)<-Inf # Setting the diagonal to Inf as an observations should be grouped with it self
  if(any(is.na(dist.rule.mat))) {stop('Distance rule matrix contains NA')}
  if(isSymmetric(dist.rule.mat)==FALSE) {stop('Distance rule matrix is not symmetrical')}

  return(dist.rule.mat)
}
