# Random Forest Regression
rm(list = ls())   #limpa o workspace
cat("\014")       #limpa o console

# importa base de dados
setwd("D:\\Manoela\\Dropbox\\Aulas\\Data Mining\\Aula 11 - 12 - Regressão")
dataset = read.csv('50_Startups.csv', row.names = 1)

# Divisão em base de treino e teste
# install.packages('caTools')
library(caTools)
set.seed(123)
split = sample.split(dataset$Profit, SplitRatio = 0.8)
training_set = subset(dataset, split == TRUE)
test_set = subset(dataset, split == FALSE)

# Fit da Random Forest Regression 
# install.packages('randomForest')
library(randomForest)
set.seed(1234)
regressor = randomForest(x = dataset[-5],
                         y = dataset$Profit)

#R2
y_treino = predict(regressor, training_set)
R2Treino = 1 - (sum((training_set$Profit - y_treino )^2) / 
                  sum((training_set$Profit - mean(training_set$Profit))^2)) ; R2Treino

# Prever para a base de teste
y_pred = predict(regressor, test_set)
R2Test = 1 - (sum((test_set$Profit - y_pred )^2) / 
                sum((test_set$Profit - mean(test_set$Profit))^2)) ; R2Test

#gráfico de barras do melhor modelo para a base de treino
counts <- rbind(y_treino, training_set$Profit)
barplot(counts, main="Previsões X Targets (Base de Treino)",
        xlab="Índice da linha de teste", col=c("darkblue","red"),
        beside=TRUE)
legend("topleft", legend = c("Previsões", "Targets"),cex=0.5, fill=c("darkblue","red"))

#gráfico de barras do melhor modelo para a base de teste
counts <- rbind(y_pred, test_set$Profit)
barplot(counts, main="Previsões X Targets (Base de Teste)",
        xlab="Índice da linha de teste", col=c("darkblue","red"),
        beside=TRUE)
legend("topleft", legend = c("Previsões", "Targets"),cex=0.5, fill=c("darkblue","red"))

#gráfico de resultados
library(ggplot2)

#treino
targetForecast = data.frame(training_set$Profit, y_treino)
ggplot(targetForecast, aes(y_treino, training_set.Profit)) + geom_point() +
  geom_abline(intercept = 0)

#teste
targetForecast = data.frame(test_set$Profit, y_pred)
ggplot(targetForecast, aes(y_pred, test_set.Profit)) + geom_point() +
  geom_abline(intercept = 0)

