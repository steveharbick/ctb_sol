#####################################################################
# code to train GBM with early stop
#####################################################################

  library(gbm)
  library(foreach)
  library(doMC)
  registerDoMC(nb_cores)

  out<-list()
  out$seed<-seed
  set.seed(seed)
  nb_folds<-length(K)

  for (i in 1:nb_folds)
    eval(parse(text=paste("x_",i,"<-x[[i]]",sep="")))

  # train first GBM_treestep trees
  res <- foreach (k = 1:nb_folds) %dopar% {
    fmla <- as.formula(paste("y~ ", paste(
      eval(parse(text=paste("names(x_",k,")",sep=""))), collapse= "+")))
    set.seed(seed+k)
    eval(parse(text=paste("
            gbm(fmla,data.frame(y=y,x_",k,")[- K[[k]],],distribution='gaussian',
            n.trees=GBM_treestep,n.minobsinnode=GBM_n.minobsinnode,
            interaction.depth=GBM_interaction.depth, 
            shrinkage=GBM_shrinkage, bag.fraction=GBM_bag.fraction,
            verbose =F)",sep="")))
    }

  out$yhatV<-rep(0,length(y))
  for (i in 1:nb_folds) {
    eval(parse(text=paste("fit_",i,"<-res[[i]]",sep="")))
    eval(parse(text=paste(
      "out$yhatV[K[[i]]]<-predict(fit_",i,",x_",i,"[ K[[i]],],n.trees=GBM_treestep)",sep="")))    
  }
  
  best_metric <- cor(y,out$yhatV,method="pearson")
  best_ntrees <- GBM_treestep
  print(paste("ntrees=",GBM_treestep,"- metric now =",round(best_metric,6)))
  
  # add at each step GBM_treestep trees, stop when no more gain in accuracy
  for (ntrees in seq(GBM_treestep+GBM_treestep,GBM_maxtrees,GBM_treestep)) {
    res <- foreach (k = 1:nb_folds) %dopar% {
      set.seed(seed+k)
      eval(parse(text=paste("
            gbm.more(fit_",k,",GBM_treestep)",sep="")))
    }
    for (i in 1:nb_folds) {
      eval(parse(text=paste("fit_",i,"<-res[[i]]",sep="")))
      eval(parse(text=paste(
        "out$yhatV[K[[i]]]<-predict(fit_",i,",x_",i,"[ K[[i]],],n.trees=ntrees)",sep="")))      
    }
    metric_now<-cor(y,out$yhatV,method="pearson")
    print(paste("ntrees=",ntrees,"- metric now =",round(metric_now,6)))
    if (best_metric > metric_now+GBM_local_protection_threshold) break 
    if (best_metric < metric_now) {
      best_metric <- metric_now
      best_ntrees <- ntrees
    }
  }
  out$best_ntrees<-best_ntrees
  
  out$fit<-list()
  for (i in 1:nb_folds)  {
    eval(parse(text=paste("out$fit[[i]]<-fit_",i,sep="")))
    eval(parse(text=paste(
      "out$yhatV[K[[i]]]<-predict(fit_",i,",x_",i,"[ K[[i]],],n.trees=best_ntrees)",sep="")))
    rm(list=paste("fit_",i,sep=""))
    rm(list=paste("x_",i,sep=""))
  }
  metric_now<-cor(y,out$yhatV,method="pearson")
  print(paste("best ntrees =",best_ntrees,"- metric = ",round(metric_now,6)))

  out

