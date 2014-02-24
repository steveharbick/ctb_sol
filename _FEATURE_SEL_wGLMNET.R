#####################################################################
# If training run, train model
if (RUN_TYPE=="TRAIN") {
  print("Split data indice into K folds")
  #####################################################################
  
  source("_KFolds.R")
  K<-Kfolds(seed+1,nb_folds_training,Nrows)
  
  print("Train GLMNET for feature selection")
  #####################################################################
  source("CV_GLMNET.R")
  
  GLMNET_4fs<-CV_GLMNET(x=x,
                        y=y,
                        K=K,
                        alpha=GLMNET_alpha,
                        standardize=GLMNET_standardize,
                        nb_cores=nb_cores,
                        seed=seed)
  print(cor(y,GLMNET_4fs$yhatV,method="pearson"))
    
  save(GLMNET_4fs,K,file=paste("Working_files/",Version,"_",item,"_GLMNET_4fs",DTM_name,".RData",sep=""))

} else {
  #####################################################################
  # If test run, use trained model
  load(paste("Working_files/",Version,"_",item,"_GLMNET_4fs",DTM_name,".RData",sep=""))
  GLMNET_4fs_H<-0
  for (i in 1:length(K))
    GLMNET_4fs_H<-GLMNET_4fs_H+predict(GLMNET_4fs$fit[[i]],as.matrix(x),
                                       type='response', s='lambda.min')[,1]/length(K)
  save(GLMNET_4fs_H,file=paste("Working_files/",Version,"_H_",item,"_GLMNET_4fs",DTM_name,".RData",sep=""))
}

# function to extract useful features from GLMNET coefficients
#####################################################################

fs_GLMNET_extract<-function(fit) {
  library(glmnet)
  out<-list()
  for (i in 1:length(fit)) {
    coeff<-fit[[i]]$glmnet.fit$beta[,which(fit[[i]]$lambda==fit[[i]]$lambda.min)]
    out[[i]]<-names(coeff[coeff!=0])
  }
  out
}

print("extract features from GLMNET")
#####################################################################

fs_GLMNET<-fs_GLMNET_extract(GLMNET_4fs$fit)

print("create list of reduced bin_mat")
#####################################################################

x_small<-list() 
for (i in 1:length(K)) 
  x_small[[i]]<-x[,fs_GLMNET[[i]]]
x<-x_small

#####################################################################
print("Save")
#####################################################################

save(x,K,file=paste("Working_files/",Version,ifelse(RUN_TYPE=="TEST","_H",""),"_",
                    item,"_Small2",DTM_name,".RData",sep=""))
rm(list=ls())

