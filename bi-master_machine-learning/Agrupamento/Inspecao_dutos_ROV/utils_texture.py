import numpy as np
import cv2
import os
from os.path import exists
import mahotas as mt
from skimage.util.shape import view_as_windows


def extract_texture_features(list_path_frames, final_size = (640,480)):

    features = None
    kernel_size = (160,160)
    stride = 160
    print("[INFO] Extracting haralick texture features")

    for path_frame in list_path_frames:
        image = cv2.imread(path_frame,0)
        image = cv2.resize(image, final_size)
        
        image_patches = view_as_windows(image, kernel_size, step=stride)
        image_patches = image_patches.reshape(-1,image_patches.shape[-1],image_patches.shape[-2])

        image_textures = []
        for patch in image_patches:        
            patch_textures = mt.features.haralick(patch).mean(axis=0)        
            image_textures.append(patch_textures)
        image_textures = np.stack(image_textures,axis=0).flatten()
        
        textures = np.reshape(image_textures, (1,-1))    
    
        if features is None:
            features = textures
        else:
            features = np.concatenate((features, textures),axis=0)   

    featres = (features - features.min(axis=0))/(features.max(axis=0) - features.min(axis=0))
    print("[INFO] Done!")    
    return features


def extract_textures(list_path_frames, filename_features):
    if not exists(filename_features):
        features = extract_texture_features(list_path_frames)
        with open(filename_features, 'wb') as f:
            np.save(f, features)
    else:
        with open(filename_features, 'rb') as f:
            features = np.load(f)
        
    print(features.shape)    
    return features