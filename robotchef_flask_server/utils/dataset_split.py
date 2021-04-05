import os, re
import json
import numpy as np

# check image is labeled not verified
# filename without extension
def check_verification(dirpath, name):
    txt_path = os.path.join(dirpath, name + '.json')
    if os.path.exists(txt_path):
        with open(txt_path, 'r') as json_file:
            jsonObj = json.load(json_file)
            if jsonObj['verification']:
                return True
        return False
    else:
        return False

# read files path list
def load_dataset(dirpath):
    dataset = list()
    for (dirpath, dirnames, filenames) in os.walk(dirpath):
        for filename in filenames:
            name, extension = os.path.splitext(filename)
            json_path = os.path.join(dirpath, name + '.json')

            if 'jpg' in extension and check_verification(dirpath, name):
                class_name = ""
                with open(json_path, 'r') as json_file:
                    json_data = json.load(json_file)
                    class_name = json_data['boxes']['0']['name']
                if not class_name in dataset.keys():
                    dataset[class_name] = list()
                dataset.append(os.path.join(dirpath, filename))
    return dataset

def split_set(data, test_ratio):
    shuffled_indices = np.random.permutation(len(data))
    numbef_of_datas = min(len(data), num)
    shuffled_indices = shuffled_indices[:numbef_of_datas]
    test_set_size = int(numbef_of_datas * test_ratio)
    test_indices = shuffled_indices[:test_set_size]
    train_indices = shuffled_indices[test_set_size:]
    return [data[idx] for idx in train_indices], [data[idx] for idx in test_indices]

if __name__ == "__main__":
    dir_path = "C:/Users/HookSSi/Desktop/grad portfolio/robotchef_flask_server/darknet/data/train"
    print(load_dataset_yolo(dir_path))
