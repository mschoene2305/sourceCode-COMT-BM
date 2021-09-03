rm(list = ls())

library(earth)
library(R.matlab)



runs = 150
dataDim = 18
rmseMars_mean = array(0,dataDim)
rmseMars_sigma = array(0,dataDim)

for(i in 1:dataDim){
  filename = paste("data",i,".mat",sep="")
  data <- readMat(filename)
  M = lapply(data[["dataR"]][1], dim)[[1]][2]
  N = lapply(data[["dataR"]][1], dim)[[1]][1]
  rmseMars = array(0,runs)
  
  for(j in 1:runs){
    index = 2*j
    X_dataTrain = matrix(unlist(data[["dataR"]][index-1]), ncol = M, nrow =)[,1:M-1]
    y_dataTrain = matrix(unlist(data[["dataR"]][index-1]), ncol = M, nrow =)[,M]
    X_dataTest = matrix(unlist(data[["dataR"]][index]), ncol = M, nrow =)[,1:M-1]
    y_dataTest = matrix(unlist(data[["dataR"]][index]), ncol = M, nrow =)[,M]
    
    
    
    #train MARS Model
    mars1 <- earth(
      y_dataTrain ~ .,  
      data = data.frame(cbind(X_dataTrain ,y_dataTrain)),
      degree = 1
    )
    
    # test MARS model
    y_predict <- predict(mars1, data.frame(cbind(X_dataTest ,y_dataTest)))
    rmseMars[j] <- sqrt(mean((y_predict - y_dataTest)^2))
    
  }
  rmseMars_mean[i] = mean(rmseMars)
  rmseMars_sigma[i] = sqrt(mean((rmseMars_mean[i] - rmseMars)^2))
  
}

