rm(list = ls())   #limpa o workspace
cat("\014")       #limpa o console

setwd('D:\\Manoela\\Dropbox\\Aulas\\Data Mining\\Aula 09 - 10 - Agrupamento')
dataset = read.csv('retail.csv', row.names = 1)

#install.packages('fastDummies')
library(fastDummies)
dataset <- dummy_cols(dataset, select_columns = "gender")
dataset$gender = NULL

#install.packages('dbscan')
library(dbscan)
set.seed(0)

#Par�metros:
# eps: especifica como os pontos pr�ximos devem ser considerados para serem considerados parte de um cluster.
# Se pequeno, grande parte dos dados n�o ser� agrupada. 
# Quanto maior, mais os clusters ser�o mesclados e a maioria dos objetos estar� no mesmo cluster.

# minPts: o n�mero m�nimo de pontos para formar uma regi�o densa.
# minPoints ??? D + 1. 
# Valores maiores geralmente s�o melhores para conjuntos de dados com ru�do. 

kNNdistplot(dataset, k=11)
abline(h=220, col="red")

res <- dbscan(dataset, eps = 220, minPts = 11)
res

dbscan_data = cbind(dataset, res$cluster)

#cluster1
cl1 = dbscan_data[dbscan_data$`res$cluster` == 1,]
summary(cl1)
#cluster2
cl2 = dbscan_data[dbscan_data$`res$cluster` == 2,]
summary(cl2)
#cluster3
cl3 = dbscan_data[dbscan_data$`res$cluster` == 3,]
summary(cl3)
#cluster4
cl4 = dbscan_data[dbscan_data$`res$cluster` == 4,]
summary(cl4)

#noise
noise = dbscan_data[dbscan_data$`res$cluster` == 0,]
summary(noise)

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
kmeans = kmeans(x = dataset, centers = 3)

clusters = kmeans$cluster
data = cbind(dataset,clusters) #associa��o dos dados aos seus clusters
data$clusters = as.factor(data$clusters) #convers�o da coluna de clusters em fator (para plotar)
kmeans$centers

#plotar
ggplot(data = data, aes(x = age, y = monthly_income, colour = clusters))+
  geom_point()


#HC
# Usando o dendrograma para definir o numero otimo de clusters
dendrogram = hclust(d = dist(dataset, method = 'euclidean'))
plot(dendrogram,
     main = paste('Dendrogram'),
     xlab = 'Customers',
     ylab = 'Euclidean distances')

# Rodando a clusteriz��o hierarquica
hc = hclust(d = dist(dataset, method = 'euclidean')) 
y_hc = cutree(hc, 4) #numero de clusters
y_hc

data = cbind(dataset,y_hc) #associa��o dos dados aos seus clusters
data$y_hc = as.factor(data$y_hc) #convers�o da coluna de clusters em fator (para plotar)

#plotar
ggplot(data = data, aes(x = age, y = monthly_income, colour = y_hc))+
  geom_point()


