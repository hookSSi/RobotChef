import os
import subprocess
import re
import shutil

DARKNET_PATH = "darknet/"

OBJ_NAMES_PATH = "data/obj.names"
OBJ_DATA_PATH = "data/obj.data"
BACKUP_FOLDER_PATH = "backup/"

TRAIN_DATASET_FOLDER_PATH = "data/train/"
VALID_DATASET_FOLDER_PATH = "data/valid/"

WEIGHT_FILE_PATH = "weight/yolov4-automated_best.weights"
ANCHOR_FILE_PATH = "anchors.txt"
PREV_CFG_FILE_PATH = "cfg/yolov4-automated-prev.cfg"
CFG_FILE_PATH = "cfg/yolov4-automated.cfg"

# create dataset path list txt file
def create_dataset_txt(txt_file_path, src_folder_path):
    print("%s 생성" % txt_file_path)

    txt = open(txt_file_path, 'w')

    temp = ""
    for item in os.listdir(src_folder_path):
        file_path, extension = os.path.splitext(item)
        if not '.txt' in extension:
            if os.path.exists(src_folder_path + file_path + '.txt'):
                temp = temp + src_folder_path + item + '\n'
    txt.write(temp)
    txt.close()
    return txt_file_path

def split_dataset():


def clean_dataset():
    try:
        shutil.rmtree(TRAIN_DATASET_FOLDER_PATH)
    except:
        print
    
    shutil.rmtree(VALID_DATASET_FOLDER_PATH)


def load_dataset(folder_path):



# create dataset setting files for yolo
def create_yolo_data():
    print('obj.data 파일 생성 시작')

    # read dataset classes names
    f = open(OBJ_NAMES_PATH, 'r')
    class_name_list = [name.strip() for name in f.readlines()]
    f.close()

    print(class_name_list)

    classes_num = "classes = %i\n" % len(class_name_list)
    train_txt_path = "train = %s\n" % create_dataset_txt("data/train.txt", TRAIN_DATASET_FOLDER_PATH)
    valid_txt_path = "valid = %s\n" % create_dataset_txt("data/valid.txt", VALID_DATASET_FOLDER_PATH)
    class_name_path= "names = %s\n" % OBJ_NAMES_PATH
    backup_path = "backup = %s" % BACKUP_FOLDER_PATH

    with open(OBJ_DATA_PATH, 'w') as obj_data:
        s = classes_num
        s += train_txt_path
        s += valid_txt_path
        s += class_name_path
        s += backup_path
        obj_data.write(s)

def cal_anchor(width, height):
    context = "darknet.exe detector calc_anchors data/obj.data -num_of_clusters 9 -width %d -height %d" % (width, height)
    with open("calc_anchors.cmd", 'w') as f:
        f.write(context)

    print("anchor 계산")
    proc = subprocess.Popen('calc_anchors.cmd', shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    out, err = proc.communicate()

def create_partial():
    if os.path.isfile(WEIGHT_FILE_PATH):
        print("pre-trained 모델 생성")
        proc = subprocess.Popen('partial.cmd', shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
        out, err = proc.communicate()

def apply_configure(param, value, context):
    return re.sub(r'%s.*' % param, '%s=%s' % (param, value), context)

# configure cfg file
# any value multiple of 32
def configure_cfg(width, height, learning_rate):
    # read dataset classes names
    f = open(OBJ_NAMES_PATH, 'r')
    class_name_list = [name.strip() for name in f.readlines()]
    f.close()

    classes_num = len(class_name_list)
    max_batches = classes_num * 2000
    max_batches = 10
    steps_min, steps_max = int(max_batches * 0.8), int(max_batches * 0.9)

    yolo_cfg = read_cfg(PREV_CFG_FILE_PATH)

    yolo_cfg[0]['[net]'] = apply_configure('width', width, yolo_cfg[0]['[net]'])
    yolo_cfg[0]['[net]'] = apply_configure('height', height, yolo_cfg[0]['[net]'])
    yolo_cfg[0]['[net]'] = apply_configure('learning_rate', learning_rate, yolo_cfg[0]['[net]'])
    yolo_cfg[0]['[net]'] = apply_configure('max_batches', max_batches, yolo_cfg[0]['[net]'])
    yolo_cfg[0]['[net]'] = apply_configure('steps', '%s, %s' % (steps_min, steps_max), yolo_cfg[0]['[net]'])

    # read anchors
    f = open(ANCHOR_FILE_PATH, 'r')
    anchors = f.read()
    f.close()
    filters = (classes_num + 5) * 3

    for i in range(0, len(yolo_cfg)):
        if '[yolo]' in yolo_cfg[i].keys():
            yolo_cfg[i]['[yolo]'] = apply_configure('anchors', anchors, yolo_cfg[i]['[yolo]'])
            yolo_cfg[i]['[yolo]'] = apply_configure('classes', classes_num, yolo_cfg[i]['[yolo]'])
            yolo_cfg[i-1]['[convolutional]'] = apply_configure('filters', filters, yolo_cfg[i-1]['[convolutional]'])
    
    save_cfg(CFG_FILE_PATH, yolo_cfg)
    # 훈련이 완료되면 

# save configured cfg file
def save_cfg(path, yolo_cfg):
    cfg = ""
    for subject in yolo_cfg:
        for key in subject.keys():
            cfg += key # subject
            cfg += subject[key] # context

    with open(path, 'w') as f:
        f.write(cfg)

# read exist original cfg file
def read_cfg(path):
    f = open(path, 'r')
    config = f.read()
    f.close()

    subjects = re.findall(r'\[[a-z]+\]', config)

    contexts = re.split(r'\[[a-z]+\]', config)
    contexts = list(filter(lambda x: x != '', contexts))

    yolo_cfg = list()
    for subject, context in zip(subjects, contexts):
        config = dict()
        config[subject] = context
        yolo_cfg.append(config)
    
    return yolo_cfg

# setting before to start training
def setting(width = 416, height = 416, learning_rate = 0.001, create_pretrained = False):
    create_yolo_data()
    cal_anchor(width, height)
    
    if create_pretrained:
        shutil.copyfile(CFG_FILE_PATH, PREV_CFG_FILE_PATH)
        if os.path.isfile(WEIGHT_FILE_PATH):
            create_partial()
        else:
            print("weight 파일이 존재하지 않아 pre-trained weight를 생성할 수 없습니다.")
            return

    if os.path.isfile(ANCHOR_FILE_PATH):
        configure_cfg(width, height, learning_rate)
    else:
        print("anchor 계산 결과가 없습니다.")
        return

def train_start():
    print("훈련 시작")
    try:
        proc = subprocess.Popen('train.cmd', shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
        out, err = proc.communicate()
    except:
        print("훈련실행 실패")

def calc_map():
    print("map 측정")
    try:
        proc = subprocess.Popen('calc_map.cmd', shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
        out, err = proc.communicate()

        result = re.findall(r'mean average precision.*.[0-9]+([.|,][0-9]+),', "".join(map(chr, out)))

        if(len(result) > 0):
            result = float(result[0])

        if(result > 0.8):
            print("map가 적정수준입니다.")
        else:
            print("map가 수준 미달입니다.")
    except:
        print("map 측정 실행 실패")

if __name__ == '__main__':
    try:
        os.chdir(DARKNET_PATH) # move to darknet folder
    except:
        print("darknet 폴더가 존재하지 않습니다.")

    calc_map()