#####################################################################
# If test run, load matrix generated in training
#####################################################################

if (RUN_TYPE=="TEST")
  load(paste("Working_files/",Version,"_",item,"_DTM_Chars_",nb_char_grams_max,"grams.RData",sep=""))

#####################################################################
# Produce document-term matrix based on character n-grams
#####################################################################
  
print("Produce character n-grams")
#####################################################################

NG<-lapply(EssayText,function(x) 
  names(textcnt(x, split="[[:punct:]]",method="ngram", n=nb_char_grams_max)))

#####################################################################
if (RUN_TYPE=="TRAIN") {
  print("Remove unfrequent ngrams or keep ")
  #####################################################################
  
  tmp<-data.frame(table(unlist(NG)))
  tmp<-as.character(tmp[tmp[,2]>rare_grams_thres,1])
  NGsh<-sapply(1:Nrows,function(x) NG[[x]][NG[[x]] %in% tmp])  
  
} else if (RUN_TYPE=="TEST") {
  print("Keep ngrams as in training set")
  #####################################################################
  
  NGsh<-NG
  training_ngrams<-attr(bin_mat,"dimnames")[[2]]
  NGsh<-lapply(1:Nrows,
                 function(x) NG[[x]][NG[[x]] %in% training_ngrams])    
}

# create features matrix
#####################################################################

Feat_mat<-data.frame(row_id=rep(1:Nrows,sapply(NGsh,length)),W=unlist(NGsh))

# assign number to ngrams (token)
#####################################################################

#####################################################################
if (RUN_TYPE=="TRAIN") {
  # assign number to words (token)
  #####################################################################
  Feat_mat$token<-as.numeric(as.factor(as.character(Feat_mat$W)))  
} else if (RUN_TYPE=="TEST") {
  # assign number to words (token) as in training set
  #####################################################################
  Feat_mat$W<-as.character(Feat_mat$W)
  n_grams_token<-data.frame(W=training_ngrams,token=1:length(training_ngrams))
  n_grams_token$W<-as.character(n_grams_token$W)
  Feat_mat<-merge(Feat_mat,n_grams_token)
}
  
print("Create incidence matrix")
#####################################################################

bin_mat<-as.matrix(sparseMatrix(Feat_mat$row_id,Feat_mat$token,
                                x=rep(1,nrow(Feat_mat))))
if (RUN_TYPE=="TEST" & nrow(bin_mat)<Nrows) {
  bin_mat<-rBind(bin_mat,
                 matrix(0,Nrows-nrow(bin_mat),ncol(bin_mat)))
}

# give names to column of incidence matrix
#####################################################################

if (RUN_TYPE=="TRAIN") {
  n_grams_token<-unique(Feat_mat[,c("W","token")])
  colnames(bin_mat)<-as.character(n_grams_token[order(n_grams_token$token),"W"])
} else if (RUN_TYPE=="TEST") {
  colnames(bin_mat)<-training_ngrams
}

print("Save")
#####################################################################

save(bin_mat,
     file=paste("Working_files/",Version,ifelse(RUN_TYPE=="TEST","_H",""),"_",
                item,"_DTM_Chars_",nb_char_grams_max,"grams.RData",sep=""))
rm(list=ls())
