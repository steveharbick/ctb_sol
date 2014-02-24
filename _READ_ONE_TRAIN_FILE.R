
training<-read.csv(paste(wd_path,'/Input/frompems/',item,'.tsv',sep=""), header=TRUE, 
                   sep = "\t", fileEncoding="windows-1252",quote="")

# discard Final Scores that are not numeric
training[,Response_name]<-as.numeric(as.character(training[,Response_name]))
training<-training[!is.na(training[,Response_name]),]

# convert EssayText to character format
EssayText <-as.character(training$Item_Response) 
Nrows<-length(EssayText)

# get score to be modelled
y<-training[,Response_name]

# store data
Store(EssayText,Nrows,y)

