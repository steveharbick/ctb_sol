gc()
print("############################################################")
print("# Store CV pearson score for individual models")
#####################################################################

item=item_list[1]
load(paste("Working_files/",Version,"_",item,"_Mod2Blend.RData",sep=""))
CV_pearson<-data.frame(Model=c(names(Mod2Blend)[2:ncol(Mod2Blend)],"Blend"))

for (item in item_list) {
  print(item)
  load(paste("Working_files/",Version,"_",item,"_Mod2Blend.RData",sep=""))
  for (Model in CV_pearson$Model) {
    if (Model=="Blend") {
      load(paste("Working_files/",Version,"_",item,"_NNLS.RData",sep=""))  
      CV_pearson[CV_pearson$Model=="Blend",paste("I",item,sep="")]<-cor(Mod2Blend$y,NNLS$yhatV,method="pearson")      
    } else CV_pearson[CV_pearson$Model==Model,paste("I",item,sep="")]<-cor(Mod2Blend$y,Mod2Blend[,Model],method="pearson")   
  }
}
CV_pearson$All<-rowSums(CV_pearson[,-1])
Store(CV_pearson)
gc()
CV_pearson[23,]
print("############################################################")
print("# Store CV SQWKappa score for individual models")
#####################################################################
source("_Kappa.R")
item=item_list[1]
load(paste("Working_files/",Version,"_",item,"_Mod2Blend.RData",sep=""))
CV_SQWKappa<-data.frame(Model=c(names(Mod2Blend)[2:ncol(Mod2Blend)],"Blend","Adjust1","Adjust2"))

for (item in item_list) {
  print(item)
  load(paste("Working_files/",Version,"_",item,"_Mod2Blend.RData",sep=""))
  for (Model in CV_SQWKappa$Model) {
    if (Model=="Adjust1") {
      load(paste("Working_files/",Version,"_",item,"_ADJ1.RData",sep=""))  
      CV_SQWKappa[CV_SQWKappa$Model==Model,paste("I",item,sep="")]<-SQWKappa(Mod2Blend$y,ADJ1$yhatV)      
    } else if (Model=="Adjust2") {
      load(paste("Working_files/",Version,"_",item,"_ADJ2.RData",sep=""))  
      CV_SQWKappa[CV_SQWKappa$Model==Model,paste("I",item,sep="")]<-SQWKappa(Mod2Blend$y,ADJ2$yhatV)      
    } else if (Model=="Blend") {
      load(paste("Working_files/",Version,"_",item,"_NNLS.RData",sep=""))  
      CV_SQWKappa[CV_SQWKappa$Model==Model,paste("I",item,sep="")]<-SQWKappa(Mod2Blend$y,NNLS$yhatV)      
    } else CV_SQWKappa[CV_SQWKappa$Model==Model,paste("I",item,sep="")]<-SQWKappa(Mod2Blend$y,Mod2Blend[,Model])   
  }
}

CV_SQWKappa$All<-rowSums(CV_SQWKappa[,-1])
Store(CV_SQWKappa)
gc()

source("_HUMAN_SCORING.R")
HUMAN_vs_ENGINE<-data.frame(Human_accuracy,
                            Engine_Pearson=as.numeric(round(t(CV_pearson[23,2:26]),3)),
                            Engine_SQWKappa=as.numeric(round(t(CV_SQWKappa[25,2:26]),3)))
HUMAN_vs_ENGINE$Var_Pearson<-HUMAN_vs_ENGINE$Pearson-HUMAN_vs_ENGINE$Engine_Pearson
HUMAN_vs_ENGINE$Var_SQWKappa<-HUMAN_vs_ENGINE$SQWKappa-HUMAN_vs_ENGINE$Engine_SQWKappa


colSums(HUMAN_vs_ENGINE[,-1])

