#####################################################################
# code to train RF
#####################################################################

  library(randomForest)
  library(foreach)
  library(doMC)
  registerDoMC(nb_cores)
  set.seed(seed)
  out<-list()
  out$fit<-list()
  nb_folds<-length(K)

  for (i in 1:nb_folds)
    eval(parse(text=paste("x_",i,"<-if (is.data.frame(x)) x else x[[i]]",sep="")))

  out$fit <- foreach (k = 1:nb_folds) %dopar% {
    set.seed(seed+k)
    eval(parse(text=paste("randomForest(x=x_",k,"[-K[[k]],],y=y[-K[[k]]],
            ntree=RF_ntree,mtry=RF_mtry,maxnodes=RF_maxnodes,
            nodesize=RF_nodesize,importance=RF_importance,replace=F,
            do.trace=F)",sep="")))
    }
  
  out$yhatV<-rep(0,length(y))
  for (i in 1:length(K)) {
    eval(parse(text=paste("
            out$yhatV[K[[i]]]<-predict(out$fit[[i]],x_",i,"[K[[i]],])",sep="")))
    rm(list=paste("x_",i,sep=""))
  }

  
