#####################################################################
# Function to compute and display SQWKappa per essay set and competition metric
#####################################################################

SQWKappa = function (rater.a , rater.b) {
  # ensure rater.b is a round score
  rater.b<-round(rater.b,0)
  #pairwise frequencies
  confusion.mat = table(data.frame(rater.a, rater.b))
  confusion.mat = confusion.mat / sum(confusion.mat)
  #get expected pairwise frequencies under independence
  histogram.a = table(rater.a) / length(table(rater.a))
  histogram.b = table(rater.b) / length(table(rater.b))
  expected.mat = histogram.a %*% t(histogram.b)
  expected.mat = expected.mat / sum(expected.mat)
  #get weights
  labels = as.numeric( as.vector (names(table(rater.a)))) 
  labels1 = as.numeric( as.vector (names(table(rater.b))))
  weights = outer(labels, labels1, FUN = function(x,y) (x-y)^2 )
  #calculate kappa
  kappa = 1 - sum(weights*confusion.mat)/sum(weights*expected.mat)
  kappa
}
