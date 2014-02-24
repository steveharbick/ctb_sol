
source("_Kappa.R")

#####################################################################
# function to adj with poly 2d
#####################################################################

ADJ_once<-function(x,y,d,seed) {
  set.seed(seed)
  if (d==1) {
    kappa<-function(xx) -SQWKappa(y,xx[1]+x*xx[2])
    optim(c(0,1),kappa)    
  } else {
    kappa<-function(xx) -SQWKappa(y,xx[1]+x*xx[2]+x^2*xx[3])
    optim(c(0,1,0),kappa)        
  }
}


CV_ADJ<-function(x,y,K,d,nb_cores,seed) {
  library(foreach)
  library(doMC)
  registerDoMC(nb_cores)
  set.seed(seed)
  out<-list()
  nb_folds<-length(K)
  x<-as.matrix(x)

  out$fit <- foreach (k = 1:(nb_folds+1)) %dopar% {
    if (k<=nb_folds) 
      ADJ_once(x[-K[[k]]],y[-K[[k]]],d,seed+k) else
        ADJ_once(x,y,d,seed+k)
  }
  
  out$yhatV<-rep(0,length(y))
  for (i in 1:length(K)) {
    xx<-out$fit[[i]]$par
    if (d==1)     
      out$yhatV[K[[i]]]<-pmax(min(y),pmin(max(y),
                              xx[1]+x[K[[i]]]*xx[2]))  else
      out$yhatV[K[[i]]]<-pmax(min(y),pmin(max(y),
                              xx[1]+x[K[[i]]]*xx[2]+x[K[[i]]]^2*xx[3]))  }
  out
}
