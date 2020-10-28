import os
from os import mkdir,makedirs
from os.path import join,exists,basename,splitext
from glob import glob
import cv2
import re
import numpy as np
from utils_preprocessing import extract_frames,crop_frames
from utils_pca import extract_pca
from utils_stats import extract_stats
from utils_texture import extract_textures
from utils_tensorboard import create_image_sprite,create_metadata_file,create_config_file
from natsort import natsorted

def main():
    path_root = os.getcwd()
    path_videos = join(path_root, "videos_processed")
    path_frames = join(path_root,"videos_frames")
    path_crop_frames = join(path_root,"videos_frames_crop")

    # Pre-processing
    extract_frames(path_videos, path_frames)
    crop_frames(path_frames, path_crop_frames)

    # Data Analysis
    list_path_frames = glob(join(path_crop_frames,"*.png"))
    list_path_frames = natsorted(list_path_frames, key=lambda y: y.lower())
    
    # Data Analysis using PCA
    method = "pca"
    path_logs = join(path_root,"logs",method)
    if not exists(path_logs):
        makedirs(path_logs)     
        
    image_sprite_size = (224,224)
        
    image_sprite_filename = create_image_sprite(list_path_frames, path_logs, method, image_sprite_size)
    metadata_filename = create_metadata_file(list_path_frames, path_logs, method)

    filename_features = join(path_root,'features_{}.npy'.format(method))
    features = extract_pca(list_path_frames, filename_features)

    tensor_filename = join(path_logs, 'features_{}.tsv'.format(method))
    create_config_file(path_logs, tensor_filename, features, image_sprite_filename, metadata_filename, image_sprite_size)

    # Data Analysis using mean,variance,skewness and kurtosis
    method = "stats"
    path_logs = join(path_root,"logs",method)
    if not exists(path_logs):
        makedirs(path_logs)     
        
    image_sprite_size = (224,224)
        
    image_sprite_filename = create_image_sprite(list_path_frames, path_logs, method, image_sprite_size)
    metadata_filename = create_metadata_file(list_path_frames, path_logs, method)

    filename_features = join(path_root,'features_{}.npy'.format(method))
    features = extract_stats(list_path_frames, filename_features)

    tensor_filename = join(path_logs, 'features_{}.tsv'.format(method))
    create_config_file(path_logs, tensor_filename, features, image_sprite_filename, metadata_filename, image_sprite_size)

    # Data Analysis using texture features
    method = "texture"
    path_logs = join(path_root,"logs",method)
    if not exists(path_logs):
        makedirs(path_logs)     
        
    image_sprite_size = (224,224)

    image_sprite_filename = create_image_sprite(list_path_frames, path_logs, method, image_sprite_size)
    metadata_filename = create_metadata_file(list_path_frames, path_logs, method)

    filename_features = join(path_root,'features_{}.npy'.format(method))
    features = extract_textures(list_path_frames, filename_features)

    tensor_filename = join(path_logs, 'features_{}.tsv'.format(method))
    create_config_file(path_logs, tensor_filename, features, image_sprite_filename, metadata_filename, image_sprite_size)

if __name__=='__main__':
    main()
