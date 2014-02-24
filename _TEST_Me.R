
#####################################################################
#####################################################################
# load packages
#####################################################################
#####################################################################

library(SOAR) # to store data that will be used by all models
library(Matrix) # to handle sparse matrix
library(tau) # for n-grams
library(RTextTools) # to stem words

#####################################################################
#####################################################################
# set where the models have been trained
#####################################################################
#####################################################################

setwd("~/Documents/asap3_short_answer")

#####################################################################
#####################################################################
# get access to objects on cache
#####################################################################
#####################################################################

library(SOAR)
Objects()

#####################################################################
#####################################################################
# set version and items to predict
#####################################################################
#####################################################################

# training version to be used
Version="V1"
Store(Version)

# item list
items_to_predict=
  c(
    "3_51802_VS_51802_1","5_50786_VS_50786_1","5_50868_VB_50868_1","5_50932_VS_50932_1",
    "5_53299_VB_53299_1","6_50577_VS_50577_1","6_52909_VB_52909_1","7_46115_VS_46115_1",
    "7_46121_VS_46121_1","7_46282_VS_46282_1","7_46348_VS_46348_1","7_46450_VS_46450_1",
    "7_46597_VS_46597_1","7_46793_VS_46793_1","8_46203_VB_46203_1","8_46517_VB_46517_1",
    "8_48558_VS_48558_1","8_48560_VB_48560_1","8_53040_VB_53041_1","9_45535_VS_45535_1",
    "9_48247_VB_48247_1","9_51416_VS_51416_1",
    "10_46619_VS_46619_1","11_49151_VS_49151_1",
    "11_49790_VS_49790_1")
Store(items_to_predict)

item_4valid=gsub("_VS_","_TS_",items_to_predict)
item_4valid=gsub("_VB_","_TB_",item_4valid)
Store(item_4valid)

#####################################################################
#####################################################################
# inform if it is a TRAIN or TEST RUN
#####################################################################
#####################################################################

RUN_TYPE = "TEST"
Store(RUN_TYPE)

print("############################################################")
print(RUN_TYPE) 
#####################################################################

for (item in item_4valid) {
  item_to_test<-items_to_predict[grep(item,item_4valid)]
  Store(item_to_test)
  print("############################################################")
  print(paste("Item used for training:",item))
  print(paste("Item to test:",item_to_test))
  print("############################################################")
  Store(item)
  
  print("############################################################")
  print("# Read data")
  #####################################################################
  source("_READ_ONE_TEST_FILE.R")
  
  print("############################################################")
  print("# Generate Proxies")
  print("############################################################")
  
  source("_PROXIES.R")
  
  print("############################################################")
  print("# Convert numbers into string")
  print("############################################################")
  
  source("_NUMBERS.R")
  
  print("############################################################")
  print("# Generate Document Term Matrix")
  print("############################################################")
  
  print("# based on word n-grams")
  source("_DTM_WORDS.R")
  
  print("############################################################")
  print("# based on character n-grams")
  nb_char_grams_max=nb_char_grams_max1
  source("_DTM_CHARS.R")
  nb_char_grams_max=nb_char_grams_max2
  source("_DTM_CHARS.R")
  
  gc()
  print("############################################################")
  print("# Feature selection")
  print("############################################################")
  
  seed=2013 ; Store(seed)
  for (DTM_name in c(paste("_DTM_Words_",nb_word_grams_max,"grams",sep=""))) {
    print(DTM_name)
    load(paste("Working_files/",Version,"_H_",item,DTM_name,".RData",sep=""))
    x=data.frame(bin_mat)
    source("_FEATURE_SEL_wGLMNET.R")  
    print("############################################################")
  }  
  
  for (DTM_name in c(paste("_DTM_Chars_",nb_char_grams_max1,"grams",sep=""),
                     paste("_DTM_Chars_",nb_char_grams_max2,"grams",sep=""))) {
    print(DTM_name)
    load(paste("Working_files/",Version,"_H_",item,DTM_name,".RData",sep=""))
    x=data.frame(bin_mat)
    source("_FEATURE_SEL_wRF.R")  
    print("############################################################")
  }  
  
  gc()
  print("############################################################")
  print("# Principal Component Analysis")
  print("############################################################")
  
  for (DTM_name in c(paste("_Small_DTM_Chars_",nb_char_grams_max1,"grams",sep=""),
                     paste("_Small_DTM_Chars_",nb_char_grams_max2,"grams",sep=""))) {
    print(DTM_name)
    load(paste("Working_files/",Version,"_H_",item,DTM_name,".RData",sep=""))
    source("_PCA.R")
  }
  
  gc()
  print("############################################################")
  print("# Test Trees")
  print("############################################################")
  
  DTM_name =paste("_Small2_DTM_Words_",nb_word_grams_max,"grams",sep="")
  print(DTM_name)
  load(paste("Working_files/",Version,"_H_",item,DTM_name,".RData",sep=""))
  load(paste("Working_files/",Version,"_",item,"_Trees_w",DTM_name,".RData",sep=""))
  library(gbm)
  RF_H<-GBM_H<-0
  for (i in 1:length(K)) {
    RF_H<-RF_H+predict(RF$fit[[i]],x[[i]])/length(K)
    GBM_H<-GBM_H+predict(GBM$fit[[i]],x[[i]],n.trees=GBM$best_ntrees)/length(K)
  }
  save(RF_H,GBM_H,file=paste("Working_files/",Version,"_H_",item,"_Trees_w",DTM_name,".RData",sep=""))
  
  
  gc()
  print("############################################################")
  print('ADD PROXIES')
  print("############################################################")
  DTM_name =paste("_Small2_DTM_Words_",nb_word_grams_max,"grams",sep="")
  load(paste("Working_files/",Version,"_H_",item,DTM_name,".RData",sep=""))
  load(paste("Working_files/",Version,"_H_",item,"_PROXIES.RData",sep=""))
  DTM_name<-paste(DTM_name,"_PROXIES",sep="")
  print(DTM_name)
  for (i in 1:length(x)) x[[i]]<-data.frame(x[[i]],PROXIES[,-1])
  load(paste("Working_files/",Version,"_",item,"_Trees_w",DTM_name,".RData",sep=""))
  RF_H<-GBM_H<-0
  for (i in 1:length(K)) {
    RF_H<-RF_H+predict(RF$fit[[i]],x[[i]])/length(K)
    GBM_H<-GBM_H+predict(GBM$fit[[i]],x[[i]],n.trees=GBM$best_ntrees)/length(K)
  }
  save(RF_H,GBM_H,file=paste("Working_files/",Version,"_H_",item,"_Trees_w",DTM_name,".RData",sep=""))
  
  gc()
  print("############################################################")
  print("# Test GLMNET and SVMs")
  print("############################################################")
  
  seed=675 ; Store(seed)
  for (DTM_name in c(paste("_Small2_DTM_Words_",nb_word_grams_max,"grams",sep=""),
                     paste("_Small_DTM_Chars_",nb_char_grams_max1,"grams",sep=""),
                     paste("_PCA_Small_DTM_Chars_",nb_char_grams_max1,"grams",sep=""),
                     paste("_Small_DTM_Chars_",nb_char_grams_max2,"grams",sep=""),
                     paste("_PCA_Small_DTM_Chars_",nb_char_grams_max2,"grams",sep=""))) {
    print(DTM_name)
    load(paste("Working_files/",Version,"_H_",item,DTM_name,".RData",sep=""))
    load(paste("Working_files/",Version,"_",item,"_NonTrees_w",DTM_name,".RData",sep=""))
    library(e1071)
    GLMNET_H<-SVM_lin_H<-SVM_rad_H<-0
    for (i in 1:length(K)) {
      GLMNET_H<-GLMNET_H+predict(GLMNET$fit[[i]],as.matrix(x[[i]]),
                               type='response', s='lambda.min')[,1]/length(K)
      SVM_lin_H<-SVM_lin_H+predict(SVM_lin$fit[[i]],as.matrix(x[[i]]))/length(K)
      SVM_rad_H<-SVM_rad_H+predict(SVM_rad$fit[[i]],as.matrix(x[[i]]))/length(K)        
    }
    save(GLMNET_H,SVM_lin_H,SVM_rad_H,
         file=paste("Working_files/",Version,"_H_",item,"_NonTrees_w",DTM_name,".RData",sep=""))
  }
  
  gc()
  print("############################################################")
  print("# Group Individual Predictions")
  print("############################################################")
  
  Mod2Blend<-data.frame(y=rep(NA,Nrows))
  
  for (DTM_name in c(paste("DTM_Words_",nb_word_grams_max,"grams",sep=""))) {
    print(DTM_name)
    load(paste("Working_files/",Version,"_H_",item,"_GLMNET_4fs_",DTM_name,".RData",sep=""))
    Mod2Blend<-data.frame(Mod2Blend,GLMNET_4fs_H)
    names(Mod2Blend)[ncol(Mod2Blend)]<-paste(DTM_name,c("GLMNET_4fs"),sep="_")
  }
  
  for (DTM_name in c(paste("DTM_Chars_",nb_char_grams_max1,"grams",sep=""),
                     paste("DTM_Chars_",nb_char_grams_max2,"grams",sep=""))) {
    print(DTM_name)
    load(paste("Working_files/",Version,"_H_",item,"_RF_4fs_",DTM_name,".RData",sep=""))
    Mod2Blend<-data.frame(Mod2Blend,RF_4fs_H)
    names(Mod2Blend)[ncol(Mod2Blend)]<-paste(DTM_name,c("RF_4fs"),sep="_")
  }
  
  for (DTM_name in c(paste("Small2_DTM_Words_",nb_word_grams_max,"grams",sep=""),
                     paste("Small2_DTM_Words_",nb_word_grams_max,"grams_PROXIES",sep=""))) {
    print(DTM_name)
    load(paste("Working_files/",Version,"_H_",item,"_Trees_w_",DTM_name,".RData",sep=""))
    Mod2Blend<-data.frame(Mod2Blend,RF_H,GBM_H)
    names(Mod2Blend)[ncol(Mod2Blend)+(-1:0)]<-paste(DTM_name,c("RF","GBM"),sep="_")
  }
  
  for (DTM_name in c(paste("Small2_DTM_Words_",nb_word_grams_max,"grams",sep=""),
                     paste("Small_DTM_Chars_",nb_char_grams_max1,"grams",sep=""),
                     paste("PCA_Small_DTM_Chars_",nb_char_grams_max1,"grams",sep=""),
                     paste("Small_DTM_Chars_",nb_char_grams_max2,"grams",sep=""),
                     paste("PCA_Small_DTM_Chars_",nb_char_grams_max2,"grams",sep=""))) {
    print(DTM_name)
    load(paste("Working_files/",Version,"_H_",item,"_NonTrees_w_",DTM_name,".RData",sep=""))
    Mod2Blend<-cbind(Mod2Blend,
                     GLMNET_H,
                     SVM_lin_H,
                     SVM_rad_H)
    names(Mod2Blend)[ncol(Mod2Blend)+(-2:0)]<-
      paste(DTM_name,c("GLMNET","SVM_lin","SVM_rad"),sep="_")
  }
  save(Mod2Blend,file=paste("Working_files/",Version,"_H_",item,"_Mod2Blend.RData",sep=""))
  print("############################################################")
}

gc()
print("############################################################")
print("# Predict Blend")
#####################################################################

for (item in item_4valid) {
  load(paste("Working_files/",Version,"_",item,"_NNLS.RData",sep=""))
  load(paste("Working_files/",Version,"_H_",item,"_Mod2Blend.RData",sep=""))
  NNLS_H<-0
  for (i in 1:length(NNLS$fit)) 
    NNLS_H<-NNLS_H+as.matrix(Mod2Blend[,-1])%*% NNLS$fit[[i]]/length(NNLS$fit)
  print(item)
  save(NNLS_H,file=paste("Working_files/",Version,"_H_",item,"_NNLS.RData",sep=""))
}

print("############################################################")
print("# Adjust to optimize Kappa scores")
#####################################################################

for (item in item_4valid) {
  load(paste("Working_files/",Version,"_",item,"_Mod2Blend.RData",sep=""))
  load(paste("Working_files/",Version,"_",item,"_ADJ1.RData",sep=""))
  load(paste("Working_files/",Version,"_H_",item,"_NNLS.RData",sep=""))
  ADJ1_H<-0
  for (i in 1:length(ADJ1$fit)) {
    xx<-ADJ1$fit[[i]]$par
    ADJ1_H<-ADJ1_H+(xx[1]+NNLS_H*xx[2])/length(ADJ1$fit)
  }
  ADJ1_H<-pmax(pmin(ADJ1_H,max(Mod2Blend$y)),min(Mod2Blend$y))
  print(item)
  save(ADJ1_H,file=paste("Working_files/",Version,"_H_",item,"_ADJ1.RData",sep=""))
}

print("############################################################")
# write csv output
#####################################################################

for (item_to_test in items_to_predict) {
  test<-read.csv(paste(wd_path,'/Input/frompems/',item_to_test,'.tsv',sep=""), header=TRUE, 
               sep = "\t", fileEncoding="windows-1252",quote="")
  load(paste("Working_files/",Version,"_H_",item_4valid[grep(item_to_test,items_to_predict)],"_ADJ1.RData",sep=""))
  write.csv(data.frame(test,prediction=ADJ1_H),
            paste("Output/",Version,"_",item_to_test,".csv",sep=""),row.names=F)
}
