rm(list = ls())   #limpa o workspace
cat("\014")       #limpa o console

# Instala pacotes (Comentar ap�s a primeira utiliza��o) ####
#install.packages("e1071")           # Support Vector Machine (SVM)
#install.packages("tree")            # Decision Tree
#install.packages("randomForest")    # Random Forest

# Carrega pacotes ####
library("e1071")  
library("tree")
library(randomForest)

#salva no workspace  ####
setwd("D:\\Manoela\\Dropbox\\Aulas\\Data Mining\\Aula 06\\01_Exercicios")
database = #fix#

# como a classe � num�rica, vamos converter para factor (categ�rica)
class_index = #fix#
database[,class_index] = as.factor(database[,class_index]) 

#Gera aleatoriamente os indices para base de teste (30% para teste)  ####
set.seed(0)
database = #fix#

#separa de fato a base
indexes = #fix#
train = #fix#
test = #fix#

# SVM ####

#fix#

# Decision Tree ####

#fix#

# Random Forest ####

#fix#


############## RECALL ##################################
# Salvar modelo para utiliz�-lo quando chegarem novos dados
#fix#