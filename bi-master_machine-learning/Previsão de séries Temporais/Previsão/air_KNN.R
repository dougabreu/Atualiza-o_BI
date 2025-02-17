# Previs�o de s�ries temporais
rm(list = ls())   #limpa o workspace
cat("\014")       #limpa o console

#Pacotes
#install.packages("forecast")
#install.packages("ggplot2")
#install.packages('tsfknn')
library(forecast)
library(ggplot2)
library(tsfknn)

setwd("D:\\Manoela\\Dropbox\\Aulas\\Data Mining\\Aula 11 - 12 - 13 - Regress�o + Previs�o de S�ries\\Previs�o")

# Importar a base de dados ##### 
dataset = read.csv("AirPassengers.csv", header = TRUE, row.names = 1)
summary(dataset)

#transformar dataset em timeSeries
FAT = ts(dataset, start = 1949, frequency = 12)
show(FAT)

#Gr�fico da s�rie temporal
autoplot(FAT)

#An�lise explorat�ria
seasonplot(FAT, year.labels = TRUE, 
           col = rainbow(11), 
           xlab = "M�s", ylab = "Faturamento (R$/Mil)")

# Boxplot do Faturamento (eixo y) e Ano (eixo x)
ANO = as.factor(rep(1949:1960, each=12))
t = data.frame(dataset, ANO)
ggplot(data = t, aes(y = X.Passengers, x = ANO)) +
  geom_boxplot(color = rainbow(12))

#Decomposi��o da S�rie Temporal
decomp = decompose(FAT) # decomp�e a s�rie temporal
plot(decomp)

#In-Sample e Out-of-sample
FAT
hprev = 24 # horizonte de previs�o
FATIN = window(FAT, start = 1949, end = c(1958,12)) # in-sample - treino
FATOUT = window(FAT, start = c(1959,1), end = c(1960,12)) # out-of-sample - teste

# KNN ##############################################################################
fitKNN <- knn_forecasting(FATIN, h = hprev, lags = 1:12, k=2);fitKNN
knnForecast = fitKNN$prediction

autoplot(knnForecast) +
  autolayer(FATOUT, series="Target")

# M�tricas de qualidade de ajuste
accuracy(knnForecast, FATOUT)


# Redes Neiurais ######################################################################
fitANN <- nnetar(FATIN)
annForecast = forecast(fitANN, h = hprev)

autoplot(annForecast) + autolayer(FATOUT, series="Target")

# M�tricas de qualidade de ajuste
accuracy(annForecast, FATOUT)
