rm(list = ls())   #limpa o workspace
cat("\014")       #limpa o console

# Instala pacotes (Comentar após a primeira utilização)
# install.packages('rpart')
# install.packages('rpart.plot')
# install.packages("randomForest")
# install.packages('caret')

# Carrega pacotes
library(rpart)
library(rpart.plot)
library(randomForest)
library(caret)

# Prepara o ambiente e carrega os dados do exercício
setwd("D:\\Manoela\\Dropbox\\Aulas\\Data Mining\\Aula 06 - Classificação\\01_Exercicios")
Mushroom = read.table("mushrooms.txt", header = TRUE,
                      stringsAsFactors = T)

# Gera aleatoriamente os indices para base de teste (20% para teste)
set.seed(0)
#indexes = sample(1:nrow(Mushroom), size=0.2*nrow(Mushroom)) #amostragem aleatoria
indexes = createDataPartition(Mushroom$class, p=0.2, list = FALSE) #estratificada
train = Mushroom[-indexes,]
test = Mushroom[indexes,]

# proporções
table(Mushroom$class)/nrow(Mushroom)
table(train$class)/nrow(train)
table(test$class)/nrow(test)

# ===================================================================================================

# D-Tree
control = rpart.control(cp=0.001)
tree_model <- rpart(class ~., train, control = control) #treinamento
predictionsDtree <- predict(tree_model, test, type='class') #teste
table(predictionsDtree, test$class) #matriz de confusao
acuracy = mean(predictionsDtree == test$class)
acuracy
rpart.plot(tree_model, type=5)

# Random Forest
forest_model <- randomForest(class ~., train, 
                             ntree = 100, #n de arvores
                             mtry = 10, # n de atributos para cada arvore
                             importance = TRUE, 
                             do.trace = 100)
predictionsForest = predict(forest_model, test)
table(predictionsForest, test$class)
acuracy = mean(predictionsForest == test$class)
acuracy
plot(forest_model)
legend("topright", legend=c("OOB", "0", "1"),
       col=c("black", "red", "green"), lty=1:1, cex=0.8)
#lty = line type, cex = character expansion factor

#Duas medidas de importância para rankear os atributos
varImpPlot(forest_model)
forest_model


############## RECALL ##################################
#Salvar modelo para utilizá-lo quando chegarem novos dados
save(forest_model, file = 'forest_model')


