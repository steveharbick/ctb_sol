Norvig<-scan(paste(wd_path,"/Input/norvig.txt",sep=""), what = character())
Norvig<-as.character(Norvig)
Norvig<-names(textcnt(Norvig, method="string", n=1L))

gutenberg<-scan(paste(wd_path,"/Input/gutenberg.txt",sep=""), what = character())
gutenberg<-as.character(gutenberg)
gutenberg<-names(textcnt(gutenberg, method="string", n=1L))

essay_inst<-scan(paste(wd_path,"/Input/essay_inst.txt",sep=""), what = character())
essay_inst<-as.character(essay_inst)
essay_inst<-names(textcnt(essay_inst, method="string", n=1L))

Prec_verbs<-read.csv(paste(wd_path,"/Input/precise_verbs.csv",sep=""),header=FALSE)
Prec_verbs<-as.character(Prec_verbs[,1])
Trans_words<-read.csv(paste(wd_path,"/Input/transition_words.csv",sep=""),header=FALSE)
Trans_words<-as.character(Trans_words[,1])

Acad_words<-read.csv(paste(wd_path,"/Input/academic words.csv",sep=""),header=FALSE)
my_list<-read.csv(paste(wd_path,"/Input/my_list.csv",sep=""),header=FALSE)

VOCAB<-c(Norvig,gutenberg,essay_inst,Trans_words,Prec_verbs,
         as.character(Acad_words[,1]),as.character(my_list[,1]))
VOCAB<-unique(VOCAB)
for (i in 1:length(VOCAB)) VOCAB[i]<-gsub('\n'," ",VOCAB[i])
VOCAB <-unlist(strsplit(VOCAB,split=" ",fixed=TRUE))
VOCAB<-unique(VOCAB)
VOCAB<-VOCAB[is.na(as.numeric(VOCAB))]
Store(VOCAB)

Store(Trans_words)

Prec_verbs <- sapply(Prec_verbs,function(x) wordStem(x))
Store(Prec_verbs)

str(Trans_words)

