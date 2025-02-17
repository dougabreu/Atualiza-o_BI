# Regress�o Linear M�litpla
rm(list = ls())   #limpa o workspace
cat("\014")       #limpa o console

# importa base de dados
setwd("D:\\Manoela\\Dropbox\\Aulas\\Data Mining\\Aula 11 - 12 - 13 - Regress�o + Previs�o de S�ries\\Regress�o")
dataset = read.csv('Bike.csv', row.names = 1)

# Divis�o em base de treino e teste
# install.packages('caTools')
library(caTools)
set.seed(123) #semnte para reprodu��o de resultados
split = sample.split(dataset$cnt, SplitRatio = 0.8)
training_set = subset(dataset, split == TRUE)
test_set = subset(dataset, split == FALSE)

# Regressao linear
regressor = lm(formula = cnt ~ ., data = training_set)

# modelo
summary(regressor)

# previs�o da base de teste
y_pred = predict(regressor, newdata = test_set)

#R2
R2Test = 1 - (sum((test_set$cnt - y_pred )^2) / 
                sum((test_set$cnt - mean(test_set$cnt))^2)) ; R2Test

#gr�fico de barras do melhor modelo para a base de teste
counts <- rbind(y_pred, test_set$cnt)
barplot(counts, main="Previs�es X Targets (Base de Teste)",
        xlab="�ndice da linha de teste", col=c("darkblue","red"),
        beside=TRUE)
legend("topleft", legend = c("Previs�es", "Targets"),cex=0.5, fill=c("darkblue","red"))

#gr�fico de resultados
library(ggplot2)
targetForecast = data.frame(test_set$cnt, y_pred)
ggplot(targetForecast, aes(y_pred, test_set.cnt)) + geom_point() +
  geom_abline(intercept = 0)

