import numpy as np
import cv2
from sklearn.decomposition import IncrementalPCA
import os
from os.path import exists

def ipca_fit_transform(list_path_frames, final_size = (640,480)):        
    features = None
    batch_size = 103
    ipca = IncrementalPCA(n_components=100)
    i = 0
        
    # Incremental PCA partial fit
    print("[INFO] Incremental PCA - partial fit")
    for path_frame in list_path_frames:
        image = cv2.imread(path_frame,1)    
        image = cv2.resize(image, final_size)    
        image = image/255
        image = np.reshape(image, (1,-1))

        if features is None:
            features = image
        else:
            features = np.concatenate((features, image),axis=0)

        if features.shape[0] == batch_size:
            i+=1
            print("[INFO] Partial fit of block {}/{}".format(i,int(len(list_path_frames)/batch_size)))
            ipca.partial_fit(features)
            features = None

    if features is not None:
        ipca.partial_fit(features)
    
    print("Accumulated variance: {}".format(np.sum(ipca.explained_variance_ratio_)))
    
    # Incremental PCA transform
    print("[INFO] Incremental PCA - transform")
    features_transform = None
    for i,path_frame in enumerate(list_path_frames):
        print("[INFO] Processing image {}/{}".format(i+1,len(list_path_frames)))
        image = cv2.imread(path_frame,1)    
        image = cv2.resize(image, final_size)    
        image = image/255
        image = np.reshape(image, (1,-1))
        image_transform = ipca.transform(image)

        if features_transform is None:
            features_transform = image_transform
        else:
            features_transform = np.concatenate((features_transform, image_transform),axis=0)

    print("[INFO] Done!")            
    return features_transform


def extract_pca(list_path_frames, filename_features):
    if not exists(filename_features):
        features = ipca_fit_transform(list_path_frames)
        with open(filename_features, 'wb') as f:
            np.save(f, features)
    else:
        with open(filename_features, 'rb') as f:
            features = np.load(f)
        
    print(features.shape)    
    return features
