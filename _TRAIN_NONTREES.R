  
print("############################################################")
print("Train GLMNET")
#####################################################################
source("CV_GLMNET.R")

GLMNET<-CV_GLMNET(x=x,
                  y=y,
                  K=K,
                  alpha=GLMNET_alpha,
                  standardize=GLMNET_standardize,
                  nb_cores=nb_cores,
                  seed=seed)
print(cor(y,GLMNET$yhatV,method="pearson"))

print("############################################################")
print("TRAIN SVM with linear kernel")
#####################################################################

source("CV_SVM_lin.R")

SVM_lin<-tune_SVM_lin(
  x=x,y=y,K=K,
  cost_i=SVM_lin_cost_i,
  cost_var=SVM_lin_cost_var,
  step_max=SVM_lin_step_max,
  nb_cores=nb_cores,
  seed=seed)

print("############################################################")
print("TRAIN SVM with radial kernel")
#####################################################################

source("CV_SVM_rad.R")

SVM_rad<-tune_SVM_rad(
  x=x,y=y,K=K,
  cost_i=SVM_rad_cost_i,gamma_i=SVM_rad_gamma_i,
  cost_var=SVM_rad_cost_var,gamma_var=SVM_rad_gamma_var,
  step_max=SVM_rad_step_max,
  nb_cores=nb_cores,
  seed=seed)

print("############################################################")
print("Save")
#####################################################################

save(seed,GLMNET,SVM_lin,SVM_rad,
     file=paste("Working_files/",Version,"_",item,"_NonTrees_w",DTM_name,".RData",sep=""))
rm(list=ls())
