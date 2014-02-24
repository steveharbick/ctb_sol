#####################################################################
# function to split rows
#####################################################################

Kfolds<-function(seed,k,N) {
  set.seed(seed)
  samp<-sample(1:k,N,replace=T)
  out<-list()
  for (i in 1:k) out[[i]]<-(1:N)[samp==i]
  out
}

