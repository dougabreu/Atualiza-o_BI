# Decision Tree Regression
rm(list = ls())   #limpa o workspace
cat("\014")       #limpa o console

# importa base de dados
setwd("D:\\Manoela\\Dropbox\\Aulas\\Data Mining\\Aula 11 - 12 - Regress�o")
dataset = read.csv('50_Startups.csv', row.names = 1)

# Divis�o em base de treino e teste
# install.packages('caTools')
library(caTools)
set.seed(123)
split = sample.split(dataset$Profit, SplitRatio = 0.8)
training_set = subset(dataset, split == TRUE)
test_set = subset(dataset, split == FALSE)

# Fit do modelo de �rvore de decis�o
# install.packages('rpart')
library(rpart)
regressor = rpart(formula = Profit ~ .,
                  data = training_set,
                  control = rpart.control(minsplit = 2))
#R2
y_treino = predict(regressor, training_set)
R2Treino = 1 - (sum((training_set$Profit - y_treino )^2) / 
                  sum((training_set$Profit - mean(training_set$Profit))^2)) ; R2Treino

# Prever para a base de teste
y_pred = predict(regressor, test_set)
R2Test = 1 - (sum((test_set$Profit - y_pred )^2) / 
                  sum((test_set$Profit - mean(test_set$Profit))^2)) ; R2Test

#gr�fico de barras do melhor modelo para a base de treino
counts <- rbind(y_treino, training_set$Profit)
barplot(counts, main="Previs�es X Targets (Base de Treino)",
        xlab="�ndice da linha de teste", col=c("darkblue","red"),
        beside=TRUE)
legend("topright", legend = c("Previs�es", "Targets"),cex=0.5, fill=c("darkblue","red"))

#gr�fico de barras do melhor modelo para a base de teste
counts <- rbind(y_pred, test_set$Profit)
barplot(counts, main="Previs�es X Targets (Base de Teste)",
        xlab="�ndice da linha de teste", col=c("darkblue","red"),
        beside=TRUE)
legend("topleft", legend = c("Previs�es", "Targets"),cex=0.5, fill=c("darkblue","red"))

#Treino
library(ggplot2)
targetForecastTraining_set = data.frame(training_set$Profit, y_treino)
ggplot(targetForecastTraining_set, aes(y_treino, training_set.Profit)) + geom_point() +
  geom_abline(intercept = 0)

#gr�fico de resultados
targetForecast = data.frame(test_set$Profit, y_pred)
ggplot(targetForecast, aes(y_pred, test_set.Profit)) + geom_point() +
  geom_abline(intercept = 0)

# Plot da �rvore
#install.packages(rpart.plot)
library(rpart.plot)
rpart.plot(regressor, type=5)






