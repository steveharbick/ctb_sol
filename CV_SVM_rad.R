
#####################################################################
# function to train SVM with radial kernel 
#####################################################################

CV_SVM_rad<-function(x,y,K,cost,gamma,nb_cores,seed) {
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
            cost=cost,gamma=gamma,kernel='radial',scale=FALSE)",sep="")))
  }
  
  out$yhatV<-rep(0,length(y))
  for (i in 1:length(K))
    eval(parse(text=paste("
            out$yhatV[K[[i]]]<-predict(out$fit[[i]],x_",i,"[K[[i]],])",sep="")))
  
  out
}

#####################################################################
# function to fine tune SVM with radial kernel
#####################################################################

tune_SVM_rad<-function(x,y,K,cost_i,gamma_i,cost_var,gamma_var,step_max,nb_cores,seed) {
  set.seed(seed)

  res_mat<-matrix(NA,31,31)  
  colnames(res_mat)<-round(gamma_i*gamma_var^(-15:15),12)
  rownames(res_mat)<-round(cost_i*cost_var^(-15:15),12)

  plot(gamma_i,cost_i,pch=19,log="xy",col=4,
       xlab="gamma",ylab="cost",
       xlim=range(as.numeric(colnames(res_mat))),
       ylim=range(as.numeric(rownames(res_mat))))
  
  sol<-list()
  sol$Improved<-"NO"
  sol$pos<-NA
  sol$svm_obj<-CV_SVM_rad(x,y,K,cost_i,gamma_i,nb_cores,seed)
  sol$res<-abs(cor(y,sol$svm_obj$yhatV,method="pearson"))
  sol$cost<-cost_i
  sol$gamma<-gamma_i
  print(paste("cost:",cost_i,"/ gamma:",gamma_i,"/ metric:",sol$res))
  
  res_mat[as.character(round(cost_i,12)),as.character(round(gamma_i,12))]<-sol$res      
  
  mult<-list()  
  mult[[1]]<-c(gamma=gamma_var^2,cost=cost_var^2)
  mult[[2]]<-c(gamma=gamma_var^2,cost=1)
  mult[[3]]<-c(gamma=gamma_var^2,cost=1/cost_var^2)
  mult[[4]]<-c(gamma=1,cost=1/cost_var^2)
  mult[[5]]<-c(gamma=1/gamma_var^2,cost=1/cost_var^2)
  mult[[6]]<-c(gamma=1/gamma_var^2,cost=1)
  mult[[7]]<-c(gamma=1/gamma_var^2,cost=cost_var^2)
  mult[[8]]<-c(gamma=1,cost=cost_var^2)
    
  for (pos in 1:8) {
    cost<-cost_i*mult[[pos]]['cost']
    gamma<-gamma_i*mult[[pos]]['gamma']
    points(gamma,cost,pch=1,col=1)      
    svm_obj<-CV_SVM_rad(x,y,K,cost,gamma,nb_cores,seed)
    res<-abs(cor(y,svm_obj$yhatV,method="pearson"))
    res_mat[as.character(round(cost,12)),as.character(round(gamma,12))]<-res      
    print(paste("cost:",cost,"/ gamma:",gamma,"/ metric:",res))
    if (res>sol$res) {
      sol$Improved<-"YES"
      sol$pos<-pos
      sol$res<-res
      sol$svm_obj<-svm_obj
      sol$cost<-cost
      sol$gamma<-gamma
      print(paste("Improved: YES"))
    }
  }
  points(sol$gamma,sol$cost,pch=19,col=3)      

  mult[[1]]<-c(gamma=gamma_var,cost=cost_var)
  mult[[2]]<-c(gamma=gamma_var,cost=1)
  mult[[3]]<-c(gamma=gamma_var,cost=1/cost_var)
  mult[[4]]<-c(gamma=1,cost=1/cost_var)
  mult[[5]]<-c(gamma=1/gamma_var,cost=1/cost_var)
  mult[[6]]<-c(gamma=1/gamma_var,cost=1)
  mult[[7]]<-c(gamma=1/gamma_var,cost=cost_var)
  mult[[8]]<-c(gamma=1,cost=cost_var)
    
  if (sol$Improved=="NO") {
    i<-sample(1:8,1)
    for (k in 1:8) {
      pos<-1+(i+(k)*5)%%8
      cost<-cost_i*mult[[pos]]['cost']
      gamma<-gamma_i*mult[[pos]]['gamma']
      points(gamma,cost,pch=1,col=1)      
      svm_obj<-CV_SVM_rad(x,y,K,cost,gamma,nb_cores,seed)
      res<-abs(cor(y,svm_obj$yhatV,method="pearson"))
      res_mat[as.character(round(cost,12)),as.character(round(gamma,12))]<-res      
      print(paste("cost:",cost,"/ gamma:",gamma,"/ metric:",res))
      if (res>sol$res) {
        sol$Improved<-"YES"
        sol$pos<-pos
        sol$res<-res
        sol$svm_obj<-svm_obj
        sol$cost<-cost
        sol$gamma<-gamma
        points(gamma,cost,pch=19,col=3)      
        print(paste("Improved: YES"))
        break
      }
    }
  }

  if (sol$Improved=="YES") for (i in 1:step_max) {
    sol$Improved<-"NO"
    pos<-sol$pos
    for (k in 1:8) {
      pos<-1+(-1+pos+(k-1)*(-1)^k)%%8
      cost<-sol$cost*mult[[pos]]['cost']
      gamma<-sol$gamma*mult[[pos]]['gamma']
      points(gamma,cost,pch=1,col=1)      
      if (is.na(res_mat[as.character(round(cost,12)),as.character(round(gamma,12))])) {
        svm_obj<-CV_SVM_rad(x,y,K,cost,gamma,nb_cores,seed)
        res<-abs(cor(y,svm_obj$yhatV,method="pearson"))
        res_mat[as.character(round(cost,12)),as.character(round(gamma,12))]<-res      
        print(paste("cost:",cost,"/ gamma:",gamma,"/ metric:",res))      
        if (res>sol$res) {
          sol$Improved<-"YES"
          sol$pos<-pos
          sol$res<-res
          sol$svm_obj<-svm_obj
          sol$cost<-cost
          sol$gamma<-gamma
          points(gamma,cost,pch=19,col=3)      
          print(paste("Improved: YES"))
          break
        }
      }
    }    
  }
  print(paste("best cost",sol$cost,"best gamma",sol$gamma,"/ metric:",sol$res))
  points(sol$gamma,sol$cost,pch=19,cex=2,col=2)
  
  sol$svm_obj
}
