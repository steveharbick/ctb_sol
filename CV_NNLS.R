#####################################################################
# function to train linear regression with only positive coeff
#####################################################################

CV_NNLS<-function(x,y,K,nb_cores,seed) {
  library(nnls)
  library(foreach)
  library(doMC)
  registerDoMC(nb_cores)
  set.seed(seed)
  out<-list()
  nb_folds<-length(K)
    
  out$fit <- foreach (k = 1:nb_folds) %dopar% {
    set.seed(seed+k)
    coef(nnls(as.matrix(x[-K[[k]],]),y[-K[[k]]]))
  }

  out$yhatV<-rep(0,length(y))
  for (i in 1:length(K)) out$yhatV[K[[i]]]<- as.matrix(x[K[[i]],])%*% out$fit[[i]]
  out
}

