#####################################################################
# function to train GLMNET
#####################################################################

CV_GLMNET<-function(x,y,K,alpha,standardize,nb_cores,seed) {
  library(glmnet)
  library(foreach)
  library(doMC)
  registerDoMC(nb_cores)
  set.seed(seed)
  out<-list()
  out$fit<-list()
  nb_folds<-length(K)
  
  for (i in 1:nb_folds)
    eval(parse(text=paste("x_",i,"<-as.matrix(if (length(x)!=nb_folds) x else x[[i]])",sep="")))
  rm(list="x")
  
  out$fit <- foreach (k = 1:nb_folds) %dopar% {
    set.seed(seed+k)
    eval(parse(text=paste("cv.glmnet(x_",k,"[-K[[k]],],y[-K[[k]]],
                  family='gaussian', alpha=alpha,standardize=standardize)",sep="")))
  }
  
  out$yhatV<-rep(0,length(y))
  for (i in 1:length(K))
    eval(parse(text=paste("
            out$yhatV[K[[i]]]<-predict(out$fit[[i]],x_",i,"[K[[i]],],
                          type='response', s='lambda.min')[,1]",sep="")))
  out
}
Store(CV_GLMNET)

