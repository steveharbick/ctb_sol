#####################################################################
# If training run, train model
if (RUN_TYPE=="TRAIN") {
  print("Split data indice into K folds")
  #####################################################################
  
  source("_KFolds.R")
  K<-Kfolds(seed+1,nb_folds_training,Nrows)
  
  print("Train RF for feature selection")
  #####################################################################
  
  RF_ntree=RF_4fs_ntree
  RF_mtry=RF_4fs_mtry
  RF_importance=T
  
  source("CV_RF.R")
  RF_4fs<-out ; rm(list="out")
  
  print(cor(y,RF_4fs$yhatV,method="pearson"))
  save(RF_4fs,K,file=paste("Working_files/",Version,"_",item,"_RF_4fs",DTM_name,".RData",sep=""))

} else {
  #####################################################################
  # If test run, use trained model
  load(paste("Working_files/",Version,"_",item,"_RF_4fs",DTM_name,".RData",sep=""))
  RF_4fs_H<-0
  for (i in 1:length(K))
    RF_4fs_H<-RF_4fs_H+predict(RF_4fs$fit[[i]],x)/length(K)
  save(RF_4fs_H,file=paste("Working_files/",Version,"_H_",item,"_RF_4fs",DTM_name,".RData",sep=""))
}

# function to extract useful features from RF permutation importance
#####################################################################

fs_rf_extract<-function(fit) {
  library(randomForest)
  out<-list()
  for (i in 1:length(fit)) {
    rfimp<-data.frame(importance(fit[[i]]))
    rfimp<-rfimp[order(-rfimp[,1]),]
    rfimp$cumsum<-cumsum(rfimp[,1])/sum(rfimp[,1])
    rfimp<-rfimp[rfimp$cumsum<1,]
    out[[i]]<-rownames(rfimp)    
  }
  out
}

print("extract features from RF permutation importance")
#####################################################################
  
fs_RF<-fs_rf_extract(RF_4fs$fit)

print("create list of reduced bin_mat")
#####################################################################

x_small<-list() 
for (i in 1:length(K)) 
  x_small[[i]]<-x[,fs_RF[[i]]]
x<-x_small

#####################################################################
print("Save")
#####################################################################

save(x,K,file=paste("Working_files/",Version,ifelse(RUN_TYPE=="TEST","_H",""),"_",
                    item,"_Small",DTM_name,".RData",sep=""))
rm(list=ls())

