#Script para inferencia

rm(list = ls())   #limpa o workspace
cat("\014")       #limpa o console

# pasta onde estão salvos os modelos
setwd("D:\\Manoela\\Dropbox\\Aulas\\Data Mining\\Aula 07 - Classificação")

#Carregar modelo
load("classifier")
load("preprocessparams")

#base a ser inferida
recall = read.csv('Social_Network_Ads.csv')
notInputs = c(1,4)
recall[,-notInputs] = predict(preprocessParams, recall[-notInputs])

prob_pred = predict(classifier, type = 'response', newdata = recall[-4])
y_pred = ifelse(prob_pred > 0.5, 1, 0)

table(y_pred, recall[,4])
