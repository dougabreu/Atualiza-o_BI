import os
from os.path import join,exists,basename
import cv2
import numpy as np
import csv
from tensorboard.plugins import projector


# Taken from: https://github.com/tensorflow/tensorflow/issues/6322
def images_to_sprite(data):
    """Creates the sprite image along with any necessary padding
    Args:
      data: NxHxW[x3] tensor containing the images.
    Returns:
      data: Properly shaped HxWx3 image with any necessary padding.
    """
    if len(data.shape) == 3:
        data = np.tile(data[...,np.newaxis], (1,1,1,3))
    data = data.astype(np.float32)
    min = np.min(data.reshape((data.shape[0], -1)), axis=1)
    data = (data.transpose(1,2,3,0) - min).transpose(3,0,1,2)
    max = np.max(data.reshape((data.shape[0], -1)), axis=1)
    data = (data.transpose(1,2,3,0) / max).transpose(3,0,1,2)
    # Inverting the colors seems to look better for MNIST
    #data = 1 - data

    n = int(np.ceil(np.sqrt(data.shape[0])))
    padding = ((0, n ** 2 - data.shape[0]), (0, 0),
            (0, 0)) + ((0, 0),) * (data.ndim - 3)
    data = np.pad(data, padding, mode='constant',
            constant_values=0)
    # Tile the individual thumbnails into an image.
    data = data.reshape((n, n) + data.shape[1:]).transpose((0, 2, 1, 3)
            + tuple(range(4, data.ndim + 1)))
    data = data.reshape((n * data.shape[1], n * data.shape[3]) + data.shape[4:])
    data = (data * 255).astype(np.uint8)
    return data


def create_image_sprite(list_path_frames, path_logs, method, image_size=(224,224)):
    image_sprite_filename = join(path_logs, 'image_sprite_{}.png'.format(method))
    
    if not exists(image_sprite_filename):        
        image_data = []
        for path_frame in list_path_frames:
            image = cv2.imread(path_frame,1)
            image = cv2.resize(image, image_size) 
            image_data.append(image)

        image_data = np.array(image_data)
        image_sprite = images_to_sprite(image_data)
        cv2.imwrite(image_sprite_filename, image_sprite)
    return image_sprite_filename
    
    
def create_metadata_file(list_path_frames, path_logs, method):
    metadata_filename = join(path_logs, 'metadata_{}.tsv'.format(method))
    
    if not exists(metadata_filename):        
        metadata_file = open(metadata_filename, 'w')        

        for path_frame in list_path_frames:    
            filename =  basename(path_frame)
            metadata_file.write('{}\n'.format(filename))    
        metadata_file.close()
    return metadata_filename
       
    
def create_config_file(path_logs, tensor_filename, features, image_sprite_filename, metadata_filename, image_sprite_size):    

    with open(tensor_filename, 'w') as fw:
        csv_writer = csv.writer(fw, delimiter='\t')
        csv_writer.writerows(features)

    config = projector.ProjectorConfig()
    # One can add multiple embeddings.
    embedding = config.embeddings.add()
    embedding.tensor_path = tensor_filename
    # Link this tensor to its metadata file (e.g. labels).
    embedding.metadata_path = metadata_filename
    # Comment out if you don't want sprites
    embedding.sprite.image_path = image_sprite_filename
    embedding.sprite.single_image_dim.extend([image_sprite_size[0], image_sprite_size[1]])
    # Saves a config file that TensorBoard will read during startup.
    projector.visualize_embeddings(path_logs, config)