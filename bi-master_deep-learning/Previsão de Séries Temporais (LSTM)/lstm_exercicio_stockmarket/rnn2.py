# Recurrent Neural Network - LSTM
# Parte 1 - Preprocessamento de Dados

# Importar as bibliotecas
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import os

# Importar a base de dados
path = os.chdir("D:\Manoela\Dropbox\Aulas\Deep Learning\Aula 07 - LSTM e AutoEncoder\lstm_exercicio_stockmarket")
dataset_train = pd.read_csv('Google_Stock_Price_Train.csv')
training_set = dataset_train.iloc[:, 1:2].values #só coluna da série em si

# gráfico da série temporal
plt.plot(training_set)
plt.xlabel("tempo")
plt.ylabel("Número de passageriros x10^3")
plt.title("Passageiros de avião")
plt.show()

# Normalização
from sklearn.preprocessing import MinMaxScaler
sc = MinMaxScaler(feature_range = (0, 1))
training_set_scaled = sc.fit_transform(training_set)

# Criar a estrutura de dados com janela 10 e output 1
window = 10
trainSize = len(training_set_scaled)
X_train = []
y_train = []
for i in range(window, trainSize):
    X_train.append(training_set_scaled[i-window:i, 0])
    y_train.append(training_set_scaled[i, 0])
X_train, y_train = np.array(X_train), np.array(y_train)

# Reshaping
X_train = np.reshape(X_train, (X_train.shape[0], X_train.shape[1], 1))

# Parte 2 - Construção da RNN

# Bibliotecas necessárias
from keras.models import Sequential
from keras.layers import Dense
from keras.layers import LSTM
from keras.layers import Dropout

# Initicializar a RNN
regressor = Sequential()

# Adicionar a primeira camada LSTM e Dropout 
regressor.add(LSTM(units = 100, return_sequences = True, input_shape = (X_train.shape[1], 1)))
regressor.add(Dropout(0.2))

# Adicionar a segunda camada LSTM e Dropout
regressor.add(LSTM(units = 80, return_sequences = True))
regressor.add(Dropout(0.2))

# Adicionar a terceira camada LSTM e Dropout
regressor.add(LSTM(units = 50))
regressor.add(Dropout(0.2))

# camada de saída
regressor.add(Dense(units = 1))

# Compilar a rede
regressor.compile(optimizer = 'adam', loss = 'mean_squared_error')

# Treinamento
regressor.fit(X_train, y_train, epochs = 250, batch_size = 32)

# Parte 3 - Fazer as previsões e analizar os resultados

# Base de teste
dataset_test = pd.read_csv('Google_Stock_Price_Test.csv')
real_stock_price = dataset_test.iloc[:, 1:2].values

# Contruir a estrutura para teste
dataset_total = pd.concat((dataset_train.iloc[:,1], dataset_test.iloc[:,1]), axis = 0)
testLength = len(dataset_test)
inputs = dataset_total[len(dataset_total) - testLength - window:].values
inputs = inputs.reshape(-1,1)
inputs = sc.transform(inputs)
X_test = []
for i in range(window, testLength + window): 
    X_test.append(inputs[i-window:i, 0])
X_test = np.array(X_test)
X_test = np.reshape(X_test, (X_test.shape[0], X_test.shape[1], 1))

# Fazer as previsões
predicted_stock_price = regressor.predict(X_test)
predicted_stock_price = sc.inverse_transform(predicted_stock_price)

# Visualizar os resultados de treino e teste
allTargetData = np.vstack((training_set, real_stock_price))
training_predicted_stock_price = regressor.predict(X_train)
training_predicted_stock_price = sc.inverse_transform(training_predicted_stock_price)
allForecastedData = np.vstack((training_set[0:window], training_predicted_stock_price, predicted_stock_price))
plt.plot(allTargetData, color = 'red', label = 'Real')
plt.plot(allForecastedData, color = 'blue', label = 'Previsto')
plt.title('Previsão de série temporal')
plt.xlabel('Tempo')
plt.ylabel('Preço')
plt.legend()
plt.savefig('predictions_training_test.svg')
plt.show()

# Parte 4 - Métricas de avaliação

import math
from sklearn.metrics import mean_squared_error
rmse = math.sqrt(mean_squared_error(real_stock_price, predicted_stock_price))
print('RMSE: ', rmse)

mse = mean_squared_error(real_stock_price, predicted_stock_price)
print('MSE: ',mse)

mape = np.mean(np.abs((real_stock_price - predicted_stock_price) / real_stock_price)) * 100
print('MAPE: ',mape)


