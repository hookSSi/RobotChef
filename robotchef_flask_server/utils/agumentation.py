import imgaug as ia
from imgaug import augmenters as iaa
import numpy as np
import cv2
import sys, os, re
import random
import shutil
from import_labeling import *
from dataset_split import *

path = "C:\\Users\\HookSSi\\Desktop\\grad portfolio\\dataset\\downloads\\train\\"
dst = "C:\\Users\\HookSSi\\Desktop\\grad portfolio\\ingredient_detector\\darknet\\data\\train\\"

def convertYolov3BBToImgaugBB(args, width, height):
    # height, width, depth = img.shape
    # for i in args:
    #     print (i)

    oclass = int(args[0])
    x_pos = float(args[1])
    y_pos = float(args[2])
    x_size = float(args[3])
    y_size = float(args[4])

    x1 = x_pos * width - (x_size * width / 2)
    y1 = y_pos * height - (y_size * height / 2)
    x2 = x_size * width + x1
    y2 = y_size * height + y1

    return (oclass, x1, y1, x2, y2)

def convertImgaugBBToYolov3BB(args, width, height):
    # height, width, depth = img.shape
    # for i in args:
    #     print (i)

    oclass = int(args[0])
    x1 = float(args[1])
    y1 = float(args[2])
    x2 = float(args[3])
    y2 = float(args[4])

    x_pos = x1 / width + ((x2 - x1) / width /  2)
    y_pos = y1 / height + ((y2 - y1) / height / 2)
    x_size = (x2 - x1) / width
    y_size = (y2 - y1) / height

    return_args = [oclass, x_pos, y_pos, x_size, y_size]

    # Skip BBs that fall outside YOLOv3 range
    for r in return_args[1:]:
        if r > 1: return ()
        if r < 0: return()
    return (return_args)

# 해상도만 조정
def fixed_aspect_ratio(infile, annot, dst):
    ## load 'infile' image into numpy array 'num_outfiles' times...
    img = cv2.imread(infile) #read you image

    if(len(img.shape) < 3):
        return
    height, width, depth = img.shape

    images = np.array(
        [img for _ in range(1)], dtype=np.uint8)  # 32 means create 32 enhanced images using following methods.

    ## Open YOLOv3 annotation file for image
    path, filename = os.path.split(infile)
    (name, fext) = os.path.splitext(filename)

    # Init list for BB construct
    bb_array = []

    # Obtain BB values from YOLOv3 annotation .txt file
    for line in annot.split('\n'):
        # print(line)
        vals = re.split('\s+', line.rstrip())

        imgaug_vals = convertYolov3BBToImgaugBB(vals, width, height)
        # print (imgaug_vals)

        bb_array.append(ia.BoundingBox(x1 = imgaug_vals[1],
                                    y1 = imgaug_vals[2],
                                    x2 = imgaug_vals[3],
                                    y2 = imgaug_vals[4],
                                    label = imgaug_vals[0]))

    bbs = ia.BoundingBoxesOnImage(bb_array, shape=img.shape)

    seq = iaa.Sequential(
        [
            iaa.PadToAspectRatio(1.0),
        ]
    )

    seq_det = seq.to_deterministic()

    image_aug = seq_det.augment_images([img])[0]
    height, width, depth = image_aug.shape
    bbs_aug = seq_det.augment_bounding_boxes([bbs])[0]

    outfile = open(os.path.join(dst, name + '.txt'), 'w')

    for i in range(len(bbs.bounding_boxes)):
        before = bbs.bounding_boxes[i]
        after = bbs_aug.bounding_boxes[i]

        out_vals = convertImgaugBBToYolov3BB([after.label, after.x1, after.y1, after.x2, after.y2], width, height)
        if not out_vals: continue
        out_vals = [str(i) for i in out_vals]
        outfile.write(" ".join(out_vals) + "\n")

    outfile.close()
    if os.path.getsize(outfile.name) > 0:
        cv2.imwrite(os.path.join(dst, filename), image_aug)  #write all changed images
    else:
        os.remove(outfile.name)

# 해상도 조정 + 다양한 이미지 생성
def augmentation(num_outfiles, infile, annot, dst, key):
    ## load 'infile' image into numpy array 'num_outfiles' times...
    img = cv2.imread(infile) #read you image

    if(len(img.shape) < 3):
        return
    height, width, depth = img.shape

    images = np.array(
        [img for _ in range(num_outfiles)], dtype=np.uint8)  # 32 means create 32 enhanced images using following methods.

    ## Open YOLOv3 annotation file for image
    path, filename = os.path.split(infile)
    (name, fext) = os.path.splitext(filename)

    ia.seed(1)

    # Init list for BB construct
    bb_array = []

    # Obtain BB values from YOLOv3 annotation .txt file
    for line in annot.split('\n'):
        # print(line)
        vals = re.split('\s+', line.rstrip())

        imgaug_vals = convertYolov3BBToImgaugBB(vals, width, height)
        # print (imgaug_vals)

        bb_array.append(ia.BoundingBox(x1 = imgaug_vals[1],
                                    y1 = imgaug_vals[2],
                                    x2 = imgaug_vals[3],
                                    y2 = imgaug_vals[4],
                                    label = imgaug_vals[0]))

    bbs = ia.BoundingBoxesOnImage(bb_array, shape=img.shape)

    seq = iaa.Sequential(
        [
            iaa.PadToAspectRatio(1.0),
            iaa.SomeOf((0, 5),
            [
                iaa.Affine(translate_percent={"x": (-0.2, 0.2), "y": (-0.2, 0.2)}),
                iaa.Rotate((-45, 45)),
                iaa.ShearX((-16, 16)),
                iaa.GammaContrast(gamma=(0.5, 2.0)),
                iaa.Flipud(0.5),
                iaa.Fliplr(0.5)
            ],
            random_order=True)
        ],
        random_order=True
    )

    cv2.imwrite(os.path.join(dst, key + '_' + filename), img)
    with open(os.path.join(dst, key + '_' + name + '.txt'), 'w') as txt_file:
        txt_file.write(annot)

    for idx,image in enumerate(images):
        ia.seed(random.randint(1, 100000))
        seq_det = seq.to_deterministic()
        image_aug = seq_det.augment_images([image])[0]
        height, width, depth = image_aug.shape
        bbs_aug = seq_det.augment_bounding_boxes([bbs])[0]

        outfile = open(os.path.join(dst, str(idx) + '_' + key + '-' + name + '.txt'), 'w')

        for i in range(len(bbs.bounding_boxes)):
            before = bbs.bounding_boxes[i]
            after = bbs_aug.bounding_boxes[i]

            out_vals = convertImgaugBBToYolov3BB([after.label, after.x1, after.y1, after.x2, after.y2], width, height)
            if not out_vals: continue
            out_vals = [str(i) for i in out_vals]
            outfile.write(" ".join(out_vals) + "\n")

        outfile.close()
        if os.path.getsize(outfile.name) > 0:
            cv2.imwrite(os.path.join(dst, str(idx) + '_' + key + '-' + filename), image_aug)  # write all changed images
        else:
            os.remove(outfile.name)

def augmentation_dataset_json(file_list, dst, labels_path):
    labels = get_labels(labels_path)

    for file in file_list:
        name, extension = os.path.splitext(file)

        # json to yolo format
        with open(name + '.json', 'r') as json_file:
            json_data = json.load(json_file)
            annot = import_label(json_data, labels)
        
            if annot is not None:
                print(annot)
                # augmentation(1, file, annot, dst)
                fixed_aspect_ratio(file, annot, dst)

def augmentation_dataset_yolo(file_list, dst, labels_path, num, key):
    labels = get_labels(labels_path)

    for file in file_list:
        name, extension = os.path.splitext(file)

        with open(name + '.txt', 'r') as txt_file:
            yolo_data = txt_file.readlines()
            annot = import_label_yolo(yolo_data, labels)
        
            if annot is not None:
                print(file)
                augmentation(num, file, annot, dst, key)

def move_dataset(dataset, dst_path):
    for data in dataset:
        name, extension = os.path.splitext(data)
        shutil.move(data, dst_path)
        dir_path = os.path.dirname(data)
        txt_path = os.path.join(dir_path, name + '.txt')
        if os.path.exists(txt_path):
            shutil.move(txt_path, dst_path)

def clear_dataset(dir_path):
    for dirpath, dirnames, filenames in os.walk(dir_path):
        for filename in filenames:
            file_path = os.path.join(dirpath, filename)
            os.remove(file_path)

if __name__ == '__main__':
    # clear previous dataset
    train_dir_path = "C:/Users/HookSSi/Desktop/grad portfolio/robotchef_flask_server/darknet/data/train"
    test_dir_path = "C:/Users/HookSSi/Desktop/grad portfolio/robotchef_flask_server/darknet/data/valid"
    temp_path = "C:/Users/HookSSi/Desktop/grad portfolio/robotchef_flask_server/darknet/data/temp"

    # split dataset
    dataset = load_dataset("C:/Users/HookSSi/Desktop/grad portfolio/robotchef_flask_server/static/images")
    trains, tests = split_set(dataset, 0.3)

    # split dataset
    print("데이터 셋 불러오는 중...")
    dataset = load_dataset_yolo("C:/Users/HookSSi/Desktop/grad portfolio/dataset/self")
    labels_path = "C:/Users/HookSSi/Desktop/grad portfolio/robotchef_flask_server/darknet/data/obj.names"

    print("데이터 셋 늘리는 중...")
    for key in dataset.keys():
        trains, tests = split_set(dataset[key], 500, 0.3)
        print("=={0}==".format(key))
        print("trains: " + str(len(trains)))
        print("tests: " + str(len(tests)))

        # augmentation
        augmentation_dataset_yolo(trains, temp_path, labels_path, 5, key)
        augmentation_dataset_yolo(tests, temp_path, labels_path, 5, key)

    # split dataset
    print("데이터 셋 다시 불러오는 중...")
    dataset = load_dataset_yolo(temp_path)

    for key in dataset.keys():
        trains, tests = split_set(dataset[key], 3000, 0.3)
        print("=={0}==".format(key))
        print("trains: " + str(len(trains)))
        print("tests: " + str(len(tests)))

        # augmentation
        move_dataset(trains, train_dir_path)
        move_dataset(tests, test_dir_path)
