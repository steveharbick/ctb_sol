# function to get Principal Component Analysis
#####################################################################

CV_PCA<-function(x,thres,K,nb_cores) {
  library(foreach)
  library(doMC)
  registerDoMC(nb_cores)
  out<-foreach (i = 1:length(K)) %dopar% {
    ncol_max<-min(nrow(x[[i]][-K[[i]],])*0.9,ncol(x[[i]]))
    pca<-princomp(as.matrix(x[[i]][-K[[i]],1:ncol_max]),centre=FALSE,scale=FALSE)
    col_thres<-1:min(which(cumsum(pca$sdev^2)/sum(pca$sdev^2)>thres))
    list(loadings=pca$loadings,center=pca$center,scale=pca$scale,
                            col_thres=col_thres,ncol_max=ncol_max)
  }  
  out
}

