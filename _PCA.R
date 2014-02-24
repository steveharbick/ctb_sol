library(foreach)
library(doMC)
registerDoMC(nb_cores)

#####################################################################
# If training run, train model
if (RUN_TYPE=="TRAIN") {
  source("CV_PCA.R")
  PCA<-CV_PCA(x,0.98,K,nb_cores)
  save(PCA,K,file=paste("Working_files/",Version,"_",item,"_PCA_Model",DTM_name,".RData",sep=""))    
  x<-foreach (i = 1:length(K)) %dopar% 
    data.frame(scale(as.matrix(x[[i]][,1:PCA[[i]]$ncol_max]), PCA[[i]]$center, PCA[[i]]$scale) %*% 
                 PCA[[i]]$loadings)[,PCA[[i]]$col_thres]
} else if (RUN_TYPE=="TEST") {
  load(paste("Working_files/",Version,"_",item,"_PCA_Model",DTM_name,".RData",sep=""))  
  x<-foreach (i = 1:length(K)) %dopar% 
    data.frame(scale(as.matrix(x[[i]][,1:PCA[[i]]$ncol_max]), PCA[[i]]$center, PCA[[i]]$scale) %*% 
                 PCA[[i]]$loadings)[,PCA[[i]]$col_thres]
}


save(x,K,file=paste("Working_files/",Version,ifelse(RUN_TYPE=="TEST","_H",""),"_",
                        item,"_PCA",DTM_name,".RData",sep=""))  
