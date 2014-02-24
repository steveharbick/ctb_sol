print("############################################################")
print("TRAIN RF")
#####################################################################

RF_ntree=RF_pfs_ntree
RF_mtry=RF_pfs_mtry
RF_importance=F

source("CV_RF.R")
RF<-out ; rm(list="out")

print(cor(y,RF$yhatV,method="pearson"))

print("############################################################")
print("TRAIN GBM")
#####################################################################

source("CV_GBM.R")
GBM<-out ; rm(list="out")

print("############################################################")
print("Save")
#####################################################################

save(seed,RF,GBM,
     file=paste("Working_files/",Version,"_",item,"_Trees_w",DTM_name,".RData",sep=""))
rm(list=ls())
