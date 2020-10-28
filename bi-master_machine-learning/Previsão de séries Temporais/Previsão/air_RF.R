# Previsão de séries temporais
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

#Gráfico da série temporal
autoplot(FAT)

#Análise exploratória
seasonplot(FAT, year.labels = TRUE, 
           col = rainbow(11), 
           xlab = "Mês", ylab = "Faturamento (R$/Mil)")

# Boxplot do Faturamento (eixo y) e Ano (eixo x)
ANO = as.factor(rep(1949:1960, each=12))
t = data.frame(dataset, ANO)
ggplot(data = t, aes(y = X.Passengers, x = ANO)) +
  geom_boxplot(color = rainbow(12))

#Decomposição da Série Temporal
decomp = decompose(FAT) # decompõe a série temporal
plot(decomp)

#In-Sample e Out-of-sample
FAT
hprev = 24 # horizonte de previsão
FATIN = window(FAT, start = 1949, end = c(1958,12)) # in-sample - treino
FATOUT = window(FAT, start = c(1959,1), end = c(1960,12)) # out-of-sample - teste

# Random Forest ####################################################################

#script para janelamento da base de dados
source('slidingWindow.R')
windowSize = 3
step = 1
data = slidingWindow(dataset$X.Passengers, windowSize, step)

#install.packages('randomForest')
#install.packages('caTools')
library(randomForest)
library(caTools)

# Gera aleatoriamente os indices para base de teste (20% para teste)
set.seed(0)
indexes = sample(1:nrow(data), size=0.2*nrow(data))
train = data[-indexes,]
test = data[indexes,]

# Fit da Random Forest Regression 
# install.packages('randomForest')
fitRF = randomForest(train[,1:windowSize], train[,windowSize+1])

# Prever para a base de teste
y_pred = predict(fitRF, test)
R2Test = 1 - (sum((test$V4 - y_pred )^2) / 
                sum((test$V4 - mean(test$V4))^2)) ; R2Test


#Previs�es da base teste
ggplot() + geom_line(data = test, aes(y = V4, x = 1:nrow(test)), color='blue') +
  geom_line(data = as.data.frame(y_pred), aes(y = y_pred, x = 1:nrow(test)), color='red')


