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

#salva no workspace ####
setwd("D:\\Manoela\\Dropbox\\Aulas\\Data Mining\\Aula 06 - Classifica��o\\Enviar")
database = read.table("credito.txt", header = TRUE)
database[,12] = as.factor(database[,12])

#Gera aleatoriamente os indices para base de teste (30% para teste) ####
set.seed(0)
indexes = sample(1:nrow(database), size=0.3*nrow(database))
#separa de fato a base
train = database[-indexes,]
test = database[indexes,]

# SVM ####
svm_model <- svm(CLASSE ~., train, probability =T)
predictionsSVM <- predict(svm_model, test, probability =T)
table(predictionsSVM,test$CLASSE)
acuracy = 1 - mean(predictionsSVM != test$CLASSE)
acuracy
summary(svm_model)
#cost ou C => custo das viola��es das restri��es (constante de regulariza��o do termo de Lagrange)
#gamma => define a dist�ncia de influ�ncia dos padr�es nos limites de decis�o (valores baixos => longe; valores altos => perto)

probabilidades = attr(predictionsSVM, "probabilities")
predictionsAndProbabilities = cbind(test$CLASSE, predictionsSVM, probabilidades)
View(predictionsAndProbabilities)

# Decision Tree ####
tree_model <- tree(CLASSE ~., train)
predictionsDtree <- predict(tree_model, test, type = "class")
table(predictionsDtree, test$CLASSE)
acuracy = 1 - mean(predictionsDtree != test$CLASSE)
acuracy
summary(tree_model)
plot(tree_model)
text(tree_model)

# Random Forest ####
forest_model <- randomForest(CLASSE ~., data = train, 
                                         importance = TRUE, 
                                         do.trace = 100)
predictionsForest = predict(forest_model, test)
table(predictionsForest, test$CLASSE)
acuracy = 1 - mean(predictionsForest != test$CLASSE)
acuracy
forest_model

#Plot dos erros
plot(forest_model)
legend("topright", legend=c("OOB", "0", "1"),
       col=c("black", "red", "green"), lty=1:1, cex=0.8)
#lty = line type, cex = character expansion factor

#Duas medidas de import�ncia para rankear os atributos
varImpPlot(forest_model)


############## RECALL ##################################
#Salvar modelo para utiliz�-lo quando chegarem novos dados
save(svm_model, file = 'svm_model')



