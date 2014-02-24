
#####################################################################
# function to train SVM with radial kernel 
#####################################################################

CV_SVM_lin<-function(x,y,K,cost,nb_cores,seed) {
  library(e1071)
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
    eval(parse(text=paste("svm(x=x_",k,"[-K[[k]],],y=y[-K[[k]]],
            cost=cost,kernel='linear',scale=FALSE)",sep="")))
  }
  
  out$yhatV<-rep(0,length(y))
  for (i in 1:length(K))
    eval(parse(text=paste("
            out$yhatV[K[[i]]]<-predict(out$fit[[i]],x_",i,"[K[[i]],])",sep="")))
  
  out
}


#####################################################################
# function to fine tune SVM with linear kernel
#####################################################################

tune_SVM_lin<-function(x,y,K,cost_i,cost_var,step_max,nb_cores,seed) {
  set.seed(seed)
    
  sol<-list()
  sol$Improved<-"NO"
  sol$pos<-NA
  sol$svm_obj<-CV_SVM_lin(x,y,K,cost_i,nb_cores,seed)
  sol$res<-abs(cor(y,sol$svm_obj$yhatV,method="pearson"))
  sol$cost<-cost_i
  print(paste("cost:",cost_i,"/ metric:",sol$res))
    
  mult<-c(1/cost_var,cost_var)
  
  for (pos in 1:2) {
    cost<-cost_i*mult[pos]
    svm_obj<-CV_SVM_lin(x,y,K,cost,nb_cores,seed)
    res<-abs(cor(y,svm_obj$yhatV,method="pearson"))
    print(paste("cost:",cost,"/ metric:",res))
    if (res>sol$res) {
      sol$Improved<-"YES"
      sol$pos<-pos
      sol$res<-res
      sol$svm_obj<-svm_obj
      sol$cost<-cost
      print(paste("Improved: YES"))
    }
  }

  pos<-sol$pos
  if (sol$Improved=="YES") for (i in 1:step_max) {
    cost<-sol$cost*mult[pos]
    svm_obj<-CV_SVM_lin(x,y,K,cost,nb_cores,seed)
    res<-abs(cor(y,svm_obj$yhatV,method="pearson"))
    print(paste("cost:",cost,"/ metric:",res))      
    if (res<sol$res) break
    if (res>sol$res) {
      sol$res<-res
      sol$svm_obj<-svm_obj
      sol$cost<-cost
      print(paste("Improved: YES"))
    }
  }
  print(paste("best cost",sol$cost,"/ metric:",sol$res))
  
  sol$svm_obj
}
