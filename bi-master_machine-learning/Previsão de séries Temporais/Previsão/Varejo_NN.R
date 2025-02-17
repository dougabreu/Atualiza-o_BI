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
dataset = read.table("fatvarejo.csv", sep = ";", dec = ",", header = TRUE)
dataset$ANO = as.factor(dataset$ANO) # transformar em fator
summary(dataset)

#transformar dataset em timeSeries
FAT = ts(dataset$FAT, start = 2003, frequency = 12)
show(FAT)

#Gr�fico da s�rie temporal
autoplot(FAT)

#An�lise explorat�ria
seasonplot(FAT, year.labels = TRUE, 
           col = rainbow(11), 
           xlab = "M�s", ylab = "Faturamento (R$/Mil)")

# Boxplot do Faturamento (eixo y) e Ano (eixo x)
ggplot(data = dataset, 
       aes(y = FAT, x = ANO)) +
  geom_boxplot(color = rainbow(11))

#Decomposi��o da S�rie Temporal
decomp = decompose(FAT) # decomp�e a s�rie temporal
plot(decomp)

#In-Sample e Out-of-sample
FAT
hprev = 24 # horizonte de previs�o
FATIN = window(FAT, start = 2003, end = c(2011,12)) # in-sample - treino
FATOUT = window(FAT, start = c(2012,1), end = c(2013,12)) # out-of-sample - teste

# Redes Neiurais ######################################################################
fitANN <- nnetar(FATIN, size=9, p=12, P=3)
annForecast = forecast(fitANN, h = hprev)

autoplot(annForecast) + autolayer(FATOUT, series="Target")

# Métricas de qualidade de ajuste
accuracy(annForecast, FATOUT)

