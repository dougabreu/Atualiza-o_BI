from keras.preprocessing.image import ImageDataGenerator
from sklearn.model_selection import train_test_split
import matplotlib.pylab as plt
import numpy as np
np.random.seed(1671) 


def PlotHistory(history):    
    print(history.history.keys())
    # summarize history for accuracy
    plt.plot(history.history['accuracy'])
    plt.plot(history.history['val_accuracy'])
    plt.title('model accuracy')
    plt.ylabel('accuracy')
    plt.xlabel('epoch')
    plt.legend(['train', 'test'], loc='upper left')
    plt.show()
    # summarize history for loss
    plt.plot(history.history['loss'])
    plt.plot(history.history['val_loss'])
    plt.title('model loss')
    plt.ylabel('loss')
    plt.xlabel('epoch')
    plt.legend(['train', 'test'], loc='upper left')
    plt.show()
    
def GetDataTest():

    datagen = ImageDataGenerator(rescale=1./255)
    generator = datagen.flow_from_directory('yalefaces', 
                                            target_size=(224, 224), 
                                            batch_size=500, 
                                            shuffle=True)

    X , y = generator.next()
    return X,y

def GetRawDataGenerators(chuck=1):

    datagen = ImageDataGenerator()
    num_data = len(datagen.flow_from_directory('yalefaces',
                                               batch_size=1).classes)

    generator = datagen.flow_from_directory('yalefaces', 
                                            target_size=(224, 224), 
                                            batch_size=num_data, 
                                            shuffle=False)

    X , y = generator.next()

    X_train, X_test, y_train, y_test = train_test_split(X, y, 
                                                        test_size=0.2, 
                                                        random_state=42)
    
    len_train = len(X_train)//chuck
    len_test = len(X_test)//chuck
    
    train_datagen = ImageDataGenerator(rescale=1./255, 
                                   shear_range=0.2, 
                                   zoom_range=0.2, 
                                   horizontal_flip=True)

    valid_datagen = ImageDataGenerator(rescale=1./255)

    train_generator = train_datagen.flow(X_train, y_train, 
                                         batch_size=len_train, 
                                         shuffle=False)

    valid_generator = valid_datagen.flow(X_test, y_test, 
                                         batch_size=len_test, 
                                         shuffle=False)
    
    return X, y, train_generator , valid_generator



def GetDataGenerators(chuck=10):
   
    len_train = 2000//chuck
    len_test = 500//chuck
    
    train_datagen = ImageDataGenerator(rescale=1./255, 
                                   shear_range=0.2, 
                                   zoom_range=0.2, 
                                   horizontal_flip=True)

    valid_datagen = ImageDataGenerator(rescale=1./255)

    train_generator = train_datagen.flow_from_directory('../data/train', 
                                         target_size=(224, 224),
                                         batch_size=len_train, 
                                         shuffle=False)

    valid_generator = valid_datagen.flow_from_directory('../data/valid', 
                                         target_size=(224, 224),
                                         batch_size=len_test, 
                                         shuffle=False)
    
    return train_generator , valid_generator