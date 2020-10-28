slidingWindow <- function(data, window, step){
  nrows = length(data) -window
  ncols = window+step
  newData <- matrix(data=NA, nrow = nrows, ncol = ncols)
  line = 1
  first = 1
  last = first+window
  
  for(i in 1:nrows)
  {
    newData[line,1:ncols] = data[first:last]
    first = first +1
    last = last +1
    line = line +1
  }
  return(as.data.frame(newData))
}