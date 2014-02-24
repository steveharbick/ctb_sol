source("_Kappa.R")

i=0
for (item in item_list) {
  training<-read.csv(paste(wd_path,'/Input/frompems/',item,'.tsv',sep=""), header=TRUE, 
                     sep = "\t", fileEncoding="windows-1252",quote="")
  cond<-!is.na(training$Read1_Score) & !is.na(training$Read2_Score)
  tmp<-data.frame(item=item,
               Pearson=round(cor(training$Read1_Score[cond],training$Read2_Score[cond],method="pearson"),3),
               SQWKappa=round(SQWKappa(training$Read1_Score[cond],training$Read2_Score[cond]),3))
  if (i==0) Human_accuracy=tmp else Human_accuracy<-rbind(Human_accuracy,tmp)
  i=i+1
}
  
Human_accuracy

