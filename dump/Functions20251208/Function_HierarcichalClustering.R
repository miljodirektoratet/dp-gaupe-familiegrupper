# This function is the hierarchcial clusteringer

h_clust<-function(groupingIndex, hclust_poly){
  # Run the clustering
  my.clust<-hclust(as.dist(groupingIndex^hclust_poly))
  
  # Cluster at height 1
  return(cutree(my.clust, h=1))
}
