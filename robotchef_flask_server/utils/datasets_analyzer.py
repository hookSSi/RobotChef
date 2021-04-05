import sys, os, re

# read files path list
def load_dataset(dirpath):
    dataset = list()
    for (dirpath, dirnames, filenames) in os.walk(dirpath):
        for filename in filenames:
            name, extension = os.path.splitext(filename)
            if 'jpg' in extension:
                dataset.append(os.path.join(dirpath, name + '.txt'))
    return dataset

def counting_classes(datasets):
    result = dict()

    for data in datasets:
        with open(data, 'r') as label_txt_file:
            annot = label_txt_file.read()
            class_set = set()
            for line in annot.split('\n'):
                if(line != ''):
                    vals = re.split('\s+', line.rstrip())
                    class_set.add(vals[0])
        for class_name in class_set:
            if class_name in result.keys():
                result[class_name] = result[class_name] + 1
            else:
                result[class_name] = 1
    return result

def print_result(dic):
    for key in dic.keys():
        print(key + " : " + str(dic[key]))

dir_path = "C:/Users/HookSSi/Desktop/DarkLabel2.3"
datasets = load_dataset(dir_path)
result = counting_classes(datasets)
print_result(result)
