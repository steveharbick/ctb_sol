# check if test prediction distributions consistent with training

par(mfrow=c(5,5))
par(mar=c(1,1,3,1))
for (item in item_4valid) {
  load(paste("Working_files/",Version,"_",item,"_NNLS.RData",sep=""))
  load(paste("Working_files/",Version,"_H_",item,"_NNLS.RData",sep=""))
  plot(density(NNLS$yhatV),main=paste(item))
  lines(density(NNLS_H),col=2)
}

par(mfrow=c(5,5))
par(mar=c(1,1,3,1))
for (item in item_4valid) {
  load(paste("Working_files/",Version,"_",item,"_ADJ1.RData",sep=""))
  load(paste("Working_files/",Version,"_H_",item,"_ADJ1.RData",sep=""))
  plot(density(ADJ1$yhatV),main=paste(item))
  lines(density(ADJ1_H),col=2)
}

