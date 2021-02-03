import os

# 이미지를 전처리하는 코드

def rename_multiple_files(path,obj):
    i=0
    for filename in os.listdir(path):
        try:
            src=path+filename
            dst=path+obj+str(i)+'.jpg'
            os.rename(src,dst)
            i+=1
            #print('Rename successful.')
        except:
            i+=1

# path='C:\\Users\HookSSi\\Desktop\\grad portfolio\\recipe_db_generator\\Images\\tomato\\'
# obj='tomato_'
# rename_multiple_files(path,obj)

from PIL import Image
import os
def resize_multiple_images(src_path, dst_path, size = 512):
    # Here src_path is the location where images are saved.
    for filename in os.listdir(src_path):
        try:
            img=Image.open(src_path+filename)
            new_img = img.resize((size, size))
            if not os.path.exists(dst_path):
                os.makedirs(dst_path)
            new_img.save(dst_path+filename)
            #print('Resized and saved {} successfully.'.format(filename))
        except:
            continue

# src_path = 'C:\\Users\HookSSi\\Desktop\\grad portfolio\\recipe_db_generator\\Images\\tomato\\'
# dst_path = 'C:\\Users\HookSSi\\Desktop\\grad portfolio\\recipe_db_generator\\Images\\tomato_resized\\'
# resize_multiple_images(src_path, dst_path)

import numpy as np
def split_set(data, test_ratio):
    shuffled_indices = np.random.permutation(len(data))
    test_set_size = int(len(data) * test_ratio)
    test_indices = shuffled_indices[:test_set_size]
    train_indices = shuffled_indices[test_set_size:]
    return [data[idx] for idx in train_indices], [data[idx] for idx in test_indices] 

def split_images(src_path, dst_path):
    images = os.listdir(src_path)
    images, valid_images = split_set(images, 0.1)
    train_images, test_images = split_set(images, 0.2)

    # 훈련용
    new_dst_path = dst_path + 'train\\'
    for filename in train_images:
        try:
            img = Image.open(src_path+filename)
            if not os.path.exists(new_dst_path):
                os.makedirs(new_dst_path)
            img.save(new_dst_path + filename)
            #print('{} has moved in {}'.format(filename, 'train'))
        except Exception as e:
            print(e)
            continue

    # 테스트용
    new_dst_path = dst_path + 'test\\'
    for filename in test_images:
        try:
            img = Image.open(src_path+filename)
            if not os.path.exists(new_dst_path):
                os.makedirs(new_dst_path)
            img.save(new_dst_path + filename)
            #print('{} has moved in {}'.format(filename, 'test'))
        except Exception as e:
            print(e)
            continue

    # 검증용
    new_dst_path = dst_path + 'valid\\'
    for filename in valid_images:
        try:
            img = Image.open(src_path+filename)
            if not os.path.exists(new_dst_path):
                os.makedirs(new_dst_path)
            img.save(new_dst_path + filename)
            #print('{} has moved in {}'.format(filename, 'valid'))
        except Exception as e:
            print(e)
            continue

# src_path = 'C:\\Users\HookSSi\\Desktop\\grad portfolio\\recipe_db_generator\\Images\\tomato_resized\\'
# dst_path = 'C:\\Users\HookSSi\\Desktop\\grad portfolio\\recipe_db_generator\\Images\\tomato_'
# split_images(src_path, dst_path)