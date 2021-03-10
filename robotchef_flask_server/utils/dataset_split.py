import os
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
            if 'jpg' in extension and check_verification(dirpath, name):
                dataset.append(os.path.join(dirpath, filename))
    return dataset

def split_set(data, test_ratio):
    shuffled_indices = np.random.permutation(len(data))
    test_set_size = int(len(data) * test_ratio)
    test_indices = shuffled_indices[:test_set_size]
    train_indices = shuffled_indices[test_set_size:]
    return [data[idx] for idx in train_indices], [data[idx] for idx in test_indices] 