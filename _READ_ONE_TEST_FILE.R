
test<-read.csv(paste(wd_path,'/Input/frompems/',item_to_test,'.tsv',sep=""), header=TRUE, 
                   sep = "\t", fileEncoding="windows-1252",quote="")

# convert EssayText to character format
EssayText <-as.character(test$Item_Response) 
Nrows<-length(EssayText)

# if blank
cond<-nchar(EssayText)==0
EssayText[cond]<-"and"

# store data
Store(EssayText,Nrows)

