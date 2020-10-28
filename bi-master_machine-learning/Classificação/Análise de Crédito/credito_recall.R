rm(list = ls())   #limpa o workspace
cat("\014")       #limpa o console

#Setar pasta de trabalho
setwd("D:\\Manoela\\Dropbox\\Aulas\\Data Mining\\Aula 06 - Classificação\\Enviar")

#Carregar modelo
load("svm_model")

#base a ser inferida
recall = read.table("credito_sem_rotulo.txt", header = TRUE)
inferencia = predict(svm_model, recall)
View(inferencia)

#Juntar base e inferencia
baseComInferencia = cbind(recall, inferencia)
View(baseComInferencia)

