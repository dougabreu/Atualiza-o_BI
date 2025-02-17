rm(list = ls())   #limpa o workspace
cat("\014")       #limpa o console

setwd('D:\\Manoela\\Dropbox\\Aulas\\Data Mining\\Aula 09 - 10 - Agrupamento')
dataset = read.csv('bi_data.csv', header=F)

plot(dataset)

#install.packages('dbscan')
library(dbscan)

set.seed(665544)

#Par�metros:
# eps: especifica como os pontos pr�ximos devem ser considerados para serem considerados parte de um cluster.
# Se pequeno, grande parte dos dados n�o ser� agrupada. 
# Quanto maior, mais os clusters ser�o mesclados e a maioria dos objetos estar� no mesmo cluster.

# minPts: o n�mero m�nimo de pontos para formar uma regi�o densa.
# minPoints ??? D + 1. 
# Valores maiores geralmente s�o melhores para conjuntos de dados com ru�do. 

kNNdistplot(dataset, k=3)
abline(h=0.02, col="red")

model <- dbscan(dataset, eps = 0.02, minPts = 3)
model

## plot clusters and add noise (cluster 0) as crosses.
plot(dataset, col=model$cluster)
points(dataset[model$cluster==0,], pch = 3, col = "gray")

#============================================================================
#Kmeans
wcss = vector()
for (i in 1:10) 
{
  wcss[i] = kmeans(x = dataset, centers = i)$tot.withinss #sum(kmeans(dataset, i)$withinss)
}
plot(1:10,
     wcss,
     type = 'b',
     main = paste('The Elbow Method'),
     xlab = 'Number of clusters',
     ylab = 'WCSS')

# Fitting K-Means to the dataset
kmeans = kmeans(x = dataset, centers = 4)

clusters = kmeans$cluster
data = cbind(dataset,clusters) #associa��o dos dados aos seus clusters
data$clusters = as.factor(data$clusters) #convers�o da coluna de clusters em fator (para plotar)

#plotar
#install.packages("ggplot2")
library(ggplot2)
ggplot(data = data, aes(x = V1, y = V2, colour = clusters))+
  geom_point()


#HC
# Usando o dendrograma para definir o numero otimo de clusters
hc = hclust(d = dist(dataset, method = 'euclidean'))
plot(hc,
     main = paste('Dendrogram'),
     xlab = 'Customers',
     ylab = 'Euclidean distances')
 
# Rodando a clusteriz��o hierarquica
y_hc = cutree(hc, 4) #numero de clusters
y_hc

data = cbind(dataset,y_hc) #associa��o dos dados aos seus clusters
data$y_hc = as.factor(data$y_hc) #convers�o da coluna de clusters em fator (para plotar)

#plotar
ggplot(data = data, aes(x = V1, y = V2, colour = y_hc))+
  geom_point()


