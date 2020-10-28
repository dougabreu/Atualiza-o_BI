from scipy import stats
import numpy as np
import cv2
import os
from os.path import exists

def extract_stats_features(list_path_frames, final_size = (640,480)):

    features = None
    print("[INFO] Extracting: mean, variance, skewness and kurtosis")

    for path_frame in list_path_frames:
        image = cv2.imread(path_frame,1)    
        image = cv2.resize(image, final_size)
        image = image/255
        image = np.reshape(image, (1,-1))
        image_stats = stats.describe(image, axis=1)
        image_stats = np.transpose(np.stack([image_stats.mean,image_stats.variance,image_stats.skewness,image_stats.kurtosis]))
    
        if features is None:
            features = image_stats
        else:
            features = np.concatenate((features, image_stats),axis=0)

    print("[INFO] Done!")
    return features   


def extract_stats(list_path_frames, filename_features):
    if not exists(filename_features):
        features = extract_stats_features(list_path_frames)
        with open(filename_features, 'wb') as f:
            np.save(f, features)
    else:
        with open(filename_features, 'rb') as f:
            features = np.load(f)
        
    print(features.shape)    
    return features