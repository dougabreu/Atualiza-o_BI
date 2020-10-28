import os
from os import mkdir
from os.path import join,exists,basename,splitext
from glob import glob
import cv2
import re
import numpy as np

def extract_frames(path_videos, path_frames):
    print("[INFO] Extracting frames from each video...") 
        
    if not exists(path_frames):
        mkdir(path_frames)

    regex_videos = "*.mp4"
    list_videos = glob(join(path_videos, regex_videos))    

    for path_video in list_videos:
        filename,_ = splitext(basename(path_video))
        filename = re.sub('[^A-Za-z0-9]+', '', filename)

        cap = cv2.VideoCapture(path_video)    
        fps = int(cap.get(cv2.CAP_PROP_FPS))
        id_frame = 0
        id_frame_saved = 0

        while(cap.isOpened()):
            ret, frame = cap.read()
            if ret:
                id_frame+=1
                if id_frame == fps:
                    id_frame_saved +=1
                    id_frame = 0
                    frame_filename = join(path_frames,"{}_{}.png".format(filename, id_frame_saved))
                    if not exists(frame_filename):
                        cv2.imwrite(frame_filename, frame)
            else:
                break
    print("[INFO] Done!")


def get_max_contour(image_bin):
    contours,_ = cv2.findContours(image_bin,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_NONE)
    max_area = 0
    i_max_area = -1
    for i,contour in enumerate(contours):
        x,y,w,h = cv2.boundingRect(contour)
        area = w*h
        if area > max_area:
            max_area = area
            i_max_area = i

    return cv2.boundingRect(contours[i_max_area])


def remove_black_border(image_rgb):
    image_gray = cv2.cvtColor(image_rgb, cv2.COLOR_BGR2GRAY)

    _,thresh = cv2.threshold(image_gray,1,255,cv2.THRESH_BINARY)
    kernel = np.ones((7,7),np.uint8)
    thresh = cv2.morphologyEx(thresh, cv2.MORPH_OPEN, kernel, iterations=5)
    x,y,w,h = get_max_contour(thresh)                

    image_crop = image_rgb[y:y+h,x:x+w,:]
    return image_crop


def crop_frames(path_frames, path_crop_frames):
    print("[INFO] Removing black borders of all frames...")
    if not exists(path_crop_frames):
        mkdir(path_crop_frames)
        
    list_path_frames = glob(join(path_frames,"*.png"))

    for path_frame in list_path_frames:
        filename = basename(path_frame)
        filename_image_crop = join(path_crop_frames,filename)
        
        if not exists(filename_image_crop):  
            image_rgb = cv2.imread(path_frame,1)
            image_crop = remove_black_border(image_rgb)        
            cv2.imwrite(filename_image_crop,image_crop)

    print("[INFO] Done!")
