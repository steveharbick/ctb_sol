
if (RUN_TYPE=="TRAIN")
  PROXIES<-data.frame(y=y) else
    PROXIES<-data.frame(y=rep(NA,Nrows))

print("############################################################")
print("# longest string")
#####################################################################

PROXIES$string_max<-as.numeric(sapply(EssayText,function(x) max(nchar(strsplit(x,split=" ")[[1]]))))

if (sum(PROXIES$string_max>45)>0) {
  print("very long string appeared for")
  print(which(PROXIES$string_max>45))
  print("text has been replaced by cheating!")
  PROXIES$string_max[PROXIES$string_max>45]<-0
}
EssayText[PROXIES$string_max==0]<-"cheating"
Store(EssayText)

print("############################################################")
print("# Proxies based on words")
#####################################################################

# count number of words
PROXIES$NbWords<-sapply(EssayText,function(x) sum(textcnt(x,n=1,method="string")))
# count unique  words
PROXIES$UniqueWords<-sapply(EssayText,function(x) length(textcnt(x,n=1,method="string")))
# count ratio number of words / unique words
PROXIES$RUniqueWords<-PROXIES$NbWords/PROXIES$UniqueWords

print("############################################################")
print("# Proxies based on characters")
#####################################################################

# count number of characters
PROXIES$nchar<-sapply(EssayText,nchar)
#stats on words length
tmp<-t(sapply(sapply(EssayText,function(x) textcnt(x,n=1,method="string")), 
              function(x) quantile(sapply(rep(names(x),x),nchar),c(0.75,0.9,0.95,0.99))))

PROXIES$WordsLengthQ90<-tmp[,2] 
PROXIES$WordsLengthQ95<-tmp[,3] 
PROXIES$WordsLengthQ99<-tmp[,4] 

print("############################################################")
print("# Proxies based on sentences")
#####################################################################

# count nb of sentences
EssayText2<-gsub("\\?","\\.",EssayText)
EssayText2<-gsub("!","\\.",EssayText2)
for (i in 1:100) EssayText2<-gsub("\\.\\.","\\.",EssayText2)
PROXIES$NbSentences<-sapply(EssayText2,function(x) length(strsplit(x,split="\\.")[[1]]))

# count number of words per sentence
PROXIES$WordsMeanInSent<-PROXIES$NbWords/PROXIES$NbSentences

PROXIES$WordsSdInSent<-sapply(EssayText,function(x) 
  sd(sapply(strsplit(x,split = "\\.")[[1]],
             function(x) sum(textcnt(x,n=1,split="[[:space:]]",method="string")))))
PROXIES$WordsSdInSent[is.na(PROXIES$WordsSdInSent)]<--1

PROXIES$WordsMaxInSent<-sapply(EssayText,function(x) 
  max(sapply(strsplit(x,split = "\\.")[[1]],
            function(x) sum(textcnt(x,n=1,split="[[:space:]]",method="string")))))

PROXIES$WordsMinInSent<-sapply(EssayText,function(x) 
  min(sapply(strsplit(x,split = "\\.")[[1]],
            function(x) sum(textcnt(x,n=1,split="[[:space:]]",method="string")))))

print("############################################################")
print("# Proxies based on punctuation")
#####################################################################

# count nb of digits
PROXIES$Digit<-sapply(EssayText,function(x) length(strsplit(x,split = "[[:digit:]]+")[[1]]))-1

# count % of punctuation
PROXIES$Punct<-(sapply(EssayText,function(x) length(strsplit(x,split = "[[:punct:]]+")[[1]]))-1)/
  PROXIES$NbWords
#presence of quote
PROXIES$QuotM<-(sapply(strsplit(EssayText,split="\"",fixed=TRUE),length)-1)/PROXIES$NbWords
#presence of slash
PROXIES$Slash<-(sapply(strsplit(EssayText,split="/",fixed=TRUE),length)-1)/PROXIES$NbWords
#presence of exclamation mark
PROXIES$Emark<-(sapply(strsplit(EssayText,split="!",fixed=TRUE),length)-1)/PROXIES$NbWords
#presence of colon
PROXIES$Colon<-(sapply(strsplit(EssayText,split=":",fixed=TRUE),length)-1)/PROXIES$NbWords
#presence of question mark
PROXIES$Question<-(sapply(strsplit(EssayText,split="?",fixed=TRUE),length)-1)/PROXIES$NbWords

#presence of braket
PROXIES$Braket<-(sapply(strsplit(EssayText,split="(",fixed=TRUE),length)-1)/PROXIES$NbWords
#presence of comma
PROXIES$Comma<-(sapply(strsplit(EssayText,split=",",fixed=TRUE),length)-1)/PROXIES$NbWords
#presence of semicolon
PROXIES$SemiColon<-(sapply(strsplit(EssayText,split=";",fixed=TRUE),length)-1)/PROXIES$NbWords

print("############################################################")
print("# % of transition words")
#####################################################################

NTransW1<-sapply(sapply(EssayText,function(x) textcnt(x,n=1,method="string")),
                 function(x) sum((names(x) %in%  Trans_words)==TRUE))
NTransW2<-sapply(sapply(EssayText,function(x) textcnt(x,n=2,method="string")),
                 function(x) sum((names(x) %in%  Trans_words)==TRUE))
NTransW3<-sapply(sapply(EssayText,function(x) textcnt(x,n=3,method="string")),
                 function(x) sum((names(x) %in%  Trans_words)==TRUE))
NTransW4<-sapply(sapply(EssayText,function(x) textcnt(x,n=4,method="string")),
                 function(x) sum((names(x) %in%  Trans_words)==TRUE))
PROXIES$PTransW<-(NTransW1+NTransW2+NTransW3+NTransW4)/PROXIES$NbWords

print("############################################################")
print("# % of precise verbs")
#####################################################################

STEM1G = lapply(sapply(EssayText,function(x) textcnt(x,n=1,method="string")),
                function(x) wordStem(substr(names(x),1,254))) 
STEM2G = lapply(sapply(EssayText,function(x) textcnt(x,n=2,method="string")),
                function(x) wordStem(substr(names(x),1,254))) 

NPrV<-sapply(STEM1G,function(x) sum((x %in%  Prec_verbs)==TRUE))
NPrV2<-sapply(STEM2G,function(x) sum((x %in%  Prec_verbs)==TRUE))
PROXIES$PPrV<-(NPrV+NPrV2)/PROXIES$NbWords

print("############################################################")
print("# % of mispelling")
#####################################################################

NErr<-sapply(sapply(EssayText,function(x) textcnt(x,n=1,method="string")),
             function(x) sum((names(x) %in%  VOCAB)==FALSE))
PROXIES$PErr<-NErr/PROXIES$NbWords

print("############################################################")
print("# impute NAs and Inf")
#####################################################################

PROXIES[is.na(PROXIES)]<-0
PROXIES[PROXIES==Inf]<-0

print("############################################################")
print("Save")
#####################################################################

save(PROXIES,
     file=paste("Working_files/",Version,ifelse(RUN_TYPE=="TEST","_H",""),"_",item,"_PROXIES.RData",sep=""))
rm(list=ls())
