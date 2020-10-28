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

setwd("D:\\Manoela\\Dropbox\\Aulas\\Data Mining\\Aula 11 - 12 - 13 - Regressão + Previsão de Séries\\Previsão")

# Importar a base de dados ##### 
dataset = read.table("fatvarejo.csv", sep = ";", dec = ",", header = TRUE)
dataset$ANO = as.factor(dataset$ANO) # transformar em fator
summary(dataset)

#transformar dataset em timeSeries
FAT = ts(dataset$FAT, start = 2003, frequency = 12)
show(FAT)

#Gráfico da série temporal
autoplot(FAT)

#Análise exploratória
seasonplot(FAT, year.labels = TRUE, 
           col = rainbow(11), 
           xlab = "Mês", ylab = "Faturamento (R$/Mil)")

# Boxplot do Faturamento (eixo y) e Ano (eixo x)
ggplot(data = dataset, 
       aes(y = FAT, x = ANO)) +
  geom_boxplot(color = rainbow(11))

#Decomposição da Série Temporal
decomp = decompose(FAT) # decompõe a série temporal
plot(decomp)

#In-Sample e Out-of-sample
FAT
hprev = 24 # horizonte de previsão
FATIN = window(FAT, start = 2003, end = c(2011,12)) # in-sample - treino
FATOUT = window(FAT, start = c(2012,1), end = c(2013,12)) # out-of-sample - teste

# Redes Neiurais ######################################################################
fitANN <- nnetar(FATIN, size=9, p=12, P=3)
annForecast = forecast(fitANN, h = hprev)

autoplot(annForecast) + autolayer(FATOUT, series="Target")

# MÃ©tricas de qualidade de ajuste
accuracy(annForecast, FATOUT)

