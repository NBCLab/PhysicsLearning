rm(list = ls())
library(tidyverse)
library(igraph)
library("RColorBrewer")
#library(ggraph)

setwd("/Users/jessicabartley/Documents/JessicaBartley/Documents/FIU/Research/Writing/FCI_post/fciResponseHetergeneity")
fci = read.csv("fci_resp.csv", header = T)

#First to extract the bipartite network from FCI data
fci %>%
  filter(Session == "session-0") %>%
  select(Q2:Q29) -> fciPre
fci %>%
  filter(Session == "session-1") %>%
  select(Q2:Q29) -> fciPost


FCIPostNet <- matrix(data = NA, nrow = nrow(fciPost), ncol = 36)
checkFCI  <- function(x) {
  as.numeric(x==c("1","2","3","4"))}

for(k in 1:9){
  kmin <- k*4-3
  kmax <- k*4
  FCIPostNet[,kmin:kmax] <- t(sapply(fciPost[,k],checkFCI))}

#This removes items from the matrix
#FCIPostNet = FCIPostNet[,-c(1,7,10,14,18,21,28,31,34)]

FCIPostGr = graph.incidence(FCIPostNet)

PeopleGr = bipartite.projection(FCIPostGr)$proj1
QuestionGr = bipartite.projection(FCIPostGr)$proj2

#Label the nodes, making life easier later.
#V(QuestionGr)$id = c("Q2A","Q2B","Q2C","Q2D","Q3A","Q3B","Q3C","Q3D","Q6A","Q6B","Q6C","Q6D","Q7A","Q7B","Q7C","Q7D","Q8A","Q8B","Q8C","Q8D","Q12A","Q12B","Q12C","Q12D","Q14A","Q14B","Q14C","Q14D","Q27A","Q27B","Q27C","Q27D","Q29A","Q29B","Q29C","Q29D" )

#Now remove the right answers, and node 12 which was isolated.
#QuestionGr %>%
# delete_vertices(c(1,7,10,14,18,21,28,31,34,12)) -> QuGrRed

#Next up sparsification
backboneNetwork<-function(g,alpha){
  
  A<-get.adjacency(g,attr="weight")
  A<-as.matrix(A)
  #Now, convert this matrix to a probability matrix,p-matrix. The function rowSums(A) returns a vector with the sum of allthe entries in a row
  p<-A/rowSums(A)
  
  #This is the evaluation function. It takes a vector of probabilities, Q, and compares each entry with the other entries in the vector.
  
  F_hat<-function(Q){
    
    x<-vector()
    for(j in 1:length(Q)){
      x[j]<-length(which(Q!=0 & Q<=Q[j]))/length(which(Q>0))
    }
    return(x)
  }
  #The following produces a matrix, sigMatrix, with values 1 for the links that are to be kept and 0 for the links that we throw away.
  sigMatrix<-matrix(nrow = length(V(g)), ncol=length(V(g)))
  for(i in 1:length(V(g))){
    sigMatrix[i,]<-F_hat(p[i,])
  }
  sigMatrix2<-sigMatrix > 1 - alpha
  
  mode(sigMatrix2)<-"numeric"
  sigMatrix2[is.na(sigMatrix2)] <- 0
  #Now multiply the original adjacency matrix with sigMatrix to get rid of the insignificant links
  B<-sigMatrix2*A
  #Now create a graph from the new matrix.
  h<-graph.adjacency(B,mode=c("upper"),weighted=TRUE) #it can be lower, upper or directed. We should experiment with different values. 
  #V(h)$id<-V(g)$id
  return(h)
}


#BBQuestions = backboneNetwork(QuGrRed, 0.1)
BBPeople = backboneNetwork(PeopleGr, 0.01)
#A = infomap.community(BBQuestions, e.weights = V(BBQuestions)$weight)

B = infomap.community(BBPeople, e.weights = V(BBPeople)$weight)
C = as.vector(membership(B))
C = as.data.frame(C)

V(PeopleGr)$mem = membership(B)

#When we use alpha = 0.01, we end up with 13 communities. They are listed below.
communities(B)
# Write B (list of all communities) to CSV
B.df <- do.call("rbind", lapply(communities(B), as.data.frame))
write.csv(B.df, file = "communities.csv")

#key from coded ID in this script to participant ID
fci %>%
  filter(Session == "session-1") %>%
  select(Subject) -> fciPostID
fciPostID
write.csv(fciPostID, file = "idKey.csv", row.names = TRUE) # Write id key to CSV

fciPost = bind_cols(fciPost,C,fciPostID)
fciPost %>% arrange(C) %>% select(Q2:Q29) %>% as.matrix() ->a
fciPost %>% arrange(C) %>% select(Subject) -> matRowNames
rownames(a) <- matRowNames$Subject
write.csv(a, file = "responses.csv", row.names = TRUE) # Write a (fci responsese ordered by cluster) to CSV

#this gives a heatmap of the 9 question data set.
# use display.brewer.all() to see all color options
heatmap(a, Rowv = NA, Colv = NA, col=brewer.pal(9,"PRGn"))

#this gives a heatmap of the 36 question data set (all answers smeared out)
#heatmap(FCIPostNet, Rowv = NA, Colv = NA)

# get average membership per cluster accross FCI question clustering
fciqclust = read.csv("fci_charac.csv", header = T)
#for(cluster in 1:length(B)){
#  for(question in 1:9){
#    for(person in 1:length(C)){
#      qresp = a[person,question]
#        if (qresp == 1) { 
#          respid = a
#        } else if (qresp == 2) {
#          respid = b
#        } else if (qresp == 3) {
#          respid = c
#        } else if (qresp == 4) {
#          respid = d
#        } else respid = NA)
#      }
#    }
#  }
#}
