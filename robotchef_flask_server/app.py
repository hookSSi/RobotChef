# @Author: Dwivedi Chandan
# @Date:   2019-08-05T13:35:05+05:30
# @Email:  chandandwivedi795@gmail.com
# @Last modified by:   Dwivedi Chandan
# @Last modified time: 2019-08-07T11:52:45+05:30

# import the necessary packages
import numpy as np
import argparse
import time
import cv2
import os
from werkzeug.utils import secure_filename
from flask import Flask, request, Response, jsonify, render_template, redirect
import jsonpickle
import base64
from io import BytesIO
import io
import json
import glob
from PIL import Image
from uuid import uuid4

confthres = 0.3
nmsthres = 0.1
yolo_path = './'

# Initialize the Flask application
app = Flask(__name__)

def get_labels(labels_path):
    # class labels 로드
    lpath = os.path.sep.join([yolo_path, labels_path])
    LABELS = open(lpath).read().strip().split("\n")
    return LABELS

def get_colors(LABELS):
    # 각 class lables에 랜덤하게 색 할당
    np.random.seed(42)
    COLORS = np.random.randint(0, 255, size=(len(LABELS), 3), dtype="uint8")
    return COLORS

def get_weights(weights_path):
    # yolo weight 파일 주소 반환
    weightsPath = os.path.sep.join([yolo_path, weights_path])
    return weightsPath

def get_config(config_path):
    # 설정 파일 주소 반환
    configPath = os.path.sep.join([yolo_path, config_path])
    return configPath

def load_model(configPath, weightsPath):
    # 훈련된 yolo 모델을 로드
    print("[INFO] YOLO 불러오는 중...")
    net = cv2.dnn.readNetFromDarknet(configPath, weightsPath)
    return net

def image_to_byte_array(image:Image):
    imgByteArr = io.BytesIO()
    image.save(imgByteArr, format='JPEG')
    imgByteArr = imgByteArr.getvalue()
    return imgByteArr

def get_predection(image, net, LABELS, COLORS):
    (H, W) = image.shape[:2]

    ln = net.getLayerNames()
    ln = [ln[i[0] - 1] for i in net.getUnconnectedOutLayers()]

    # construct a blob from the input image and then perform a forward
    # pass of the YOLO object detector, giving us our bounding boxes and
    # associated probabilities
    blob = cv2.dnn.blobFromImage(image, 1 / 255.0, (608, 608), crop=False)

    net.setInput(blob)

    start = time.time()
    layerOutputs = net.forward(ln)
    # print(layerOutputs)
    end = time.time()

    # show timing information on YOLO
    print("[INFO] YOLO 탐지 {:.6f} 초 소요되었습니다.".format(end - start))

    # initialize our lists of detected bounding boxes, confidences, and
    # class IDs, respectively
    boxes = []
    confidences = []
    classIDs = []

    # loop over each of the layer outputs
    for output in layerOutputs:
        # loop over each of the detections
        for detection in output:
            # extract the class ID and confidence (i.e., probability) of
            # the current object detection
            scores = detection[5:]
            # print(scores)
            classID = np.argmax(scores)
            # print(classID)
            confidence = scores[classID]

            # filter out weak predictions by ensuring the detected
            # probability is greater than the minimum probability
            if confidence > confthres:
                # scale the bounding box coordinates back relative to the
                # size of the image, keeping in mind that YOLO actually
                # returns the center (x, y)-coordinates of the bounding
                # box followed by the boxes' width and height
                box = detection[0:4] * np.array([W, H, W, H])
                (centerX, centerY, width, height) = box.astype("int")

                # use the center (x, y)-coordinates to derive the top and
                # and left corner of the bounding box
                x = int(centerX - (width / 2))
                y = int(centerY - (height / 2))

                # update our list of bounding box coordinates, confidences,
                # and class IDs
                boxes.append([x, y, min(W, int(width)), min(H, int(height))])
                confidences.append(float(confidence))
                classIDs.append(classID)

                    # apply non-maxima suppression to suppress weak, overlapping bounding
    # boxes
    idxs = cv2.dnn.NMSBoxes(boxes, confidences, confthres,
                            nmsthres)

    detected_obj_list = list()

    # import copy
    # 테스트
    # 169, 547, 370, 220
    # [259, 488, 192, 197]
    # obj_test = dict()
    # rect_test = dict()

    # rect_test['x'] = 259
    # rect_test['y'] = 488
    # rect_test['w'] = 192
    # rect_test['h'] = 197

    # obj_test['rect'] = rect_test
    # obj_test['detectedClass'] = 'test'
    # obj_test['confidenceInClass'] = 0.85
    # obj_test['color'] = [int(c) for c in COLORS[1]]

    # detected_obj_list.append(copy.deepcopy(obj_test))

    # rect_test['x'] = W / 3
    # rect_test['y'] = H / 3
    # rect_test['w'] = 100
    # rect_test['h'] = 50
    # obj_test['rect'] = rect_test

    # detected_obj_list.append(copy.deepcopy(obj_test))

    # ensure at least one detection exists
    if len(idxs) > 0:
        # loop over the indexes we are keeping
        for i in idxs.flatten():
            obj = dict()
            rect = dict()

            rect['x'] = boxes[i][0] # left corner x
            rect['y'] = boxes[i][1] # left corner y
            rect['w'] = boxes[i][2] # width
            rect['h'] = boxes[i][3] # height

            obj['rect'] = rect
            obj['detectedClass'] = LABELS[classIDs[i]]
            obj['confidenceInClass'] = confidences[i]

            # 바운딩 박스 컬러 지정
            # 정해진 시드에서 미리 초기화하기 때문에 동일한 객체에 늘 같은 색깔 지정
            color = [int(c) for c in COLORS[classIDs[i]]]
            obj['color'] = color

            detected_obj_list.append(obj)

            # # extract the bounding box coordinates
            # (x, y) = (boxes[i][0], boxes[i][1])
            # (w, h) = (boxes[i][2], boxes[i][3])

            # # draw a bounding box rectangle and label on the image
            # cv2.rectangle(image, (x, y), (x + w, y + h), color, 2)
            # text = "{}: {:.4f}".format(LABELS[classIDs[i]], confidences[i])
            # cv2.putText(image, text, (x, y - 5), cv2.FONT_HERSHEY_SIMPLEX,0.5, color, 2)
            # cv2.imwrite('test.jpg', image)
    
    return image, detected_obj_list

def ajax_response(status, msg):
    status_code = "ok" if status else "error"
    return json.dumps(dict(
        status=status_code,
        msg=msg,
    ))
    
def save_json(image_path, json_data):
    print("labeling json 저장")
    dirpath, filename = os.path.split(image_path)
    name, extension = os.path.splitext(filename)
    txt_path = os.path.join(dirpath, name + '.json')

    with open(txt_path, 'w', encoding='utf-8') as json_file:
        json.dump(json_data, json_file, indent='\t')

def load_json(image_path):
    dirpath, filename = os.path.split(image_path)
    name, extension = os.path.splitext(filename)
    txt_path = os.path.join(dirpath, name + '.json')

    jsonObj = None
    with open(txt_path, 'r') as json_file:
        jsonObj = json.load(json_file)
    return jsonObj

# load image's labels
def load_labels(image_path):
    dirpath, filename = os.path.split(image_path)
    name, extension = os.path.splitext(filename)
    txt_path = os.path.join(dirpath, name + '.json')

    labels = list()
    with open(txt_path, 'r') as json_file:
        jsonObj = json.load(json_file)
        labels = jsonObj['boxes']
    return labels

# check image is labeled not verified
# filename without extension
def check_verification(dirpath, name):
    txt_path = os.path.join(dirpath, name + '.json')
    if os.path.exists(txt_path):
        with open(txt_path, 'r') as json_file:
            jsonObj = json.load(json_file)
            if not jsonObj['verification']:
                return True
        return False
    else:
        return False

# read files path list
def load_files():
    files = list()
    for (dirpath, dirnames, filenames) in os.walk(app.config["IMAGES_DIR"]):
        for filename in filenames:
            name, extension = os.path.splitext(filename)
            if 'jpg' in extension and check_verification(dirpath, name):
                files.append(os.path.join(dirpath, filename))
    app.config["FILES"] = files
    app.config["HEAD"] = 0

labelsPath="darknet/data/obj.names"
cfgpath="darknet/cfg/yolov4-automated.cfg"
wpath="darknet/weight/yolov4-automated_best.weights"
Lables=get_labels(labelsPath)
CFG=get_config(cfgpath)
Weights=get_weights(wpath)
nets=load_model(CFG,Weights)
nets.setPreferableBackend(cv2.dnn.DNN_BACKEND_CUDA)
nets.setPreferableTarget(cv2.dnn.DNN_TARGET_CUDA)
Colors=get_colors(Lables)

# auto labeling using trained yolov4 model
def auto_label(path):
    img = cv2.imread(path, cv2.IMREAD_UNCHANGED)
    result_image, result_list = get_predection(img, nets, Lables, Colors)

    H, W = result_image.shape[:2]
    labels = list()
    for item in result_list:
        label = dict()
        label['name'] = item['detectedClass']
        label['x_center'] = (item['rect']['x'] + item['rect']['w'] / 2) / W
        label['y_center'] = (item['rect']['y'] + item['rect']['h'] / 2) / H
        label['width'] = item['rect']['w'] / W
        label['height'] = item['rect']['h'] / H
        labels.append(label)

    return {'verification' : False, 'boxes' : labels}

@app.route('/detect', methods=['POST'])
def detect():
    img = request.files['image']
    image = cv2.imdecode(np.fromstring(img.read(),np.uint8), cv2.IMREAD_UNCHANGED)

    result_image, obj_list = get_predection(image, nets, Lables, Colors)
    H, W = result_image.shape[:2]

    json_data = jsonify({'data' : obj_list, 'width' : W, 'height' : H})
    print(obj_list)
    print("width:%d, height:%d" % (W, H))

    return json_data

@app.after_request
def set_response_headers(response):
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '0'
    return response

@app.route("/upload", methods=["POST"])
def upload():
    """Handle the upload of a file."""
    form = request.form

    # Create a unique "session ID" for this particular batch of uploads.
    upload_key = str(uuid4())

    # Is the upload using Ajax, or a direct POST by the form?
    is_ajax = False
    if form.get("__ajax", None) == "true":
        is_ajax = True

    # Target folder for these uploads.
    target = "static/images/{}".format(upload_key)
    try:
        os.makedirs(target)
    except:
        if is_ajax:
            return ajax_response(False, "업로드 폴더를 만들 수 없습니다.(ajax error): {}".format(target))
        else:
            return "업로드 폴더를 만들 수 없습니다.: {}".format(target)

    print("=== Form Data ===")
    for key, value in list(form.items()):
        print(key, "=>", value)

    for upload in request.files.getlist("file"):
        filename = upload.filename.rsplit("/")[0]
        destination = "/".join([target, filename])
        print("파일 받는 중:", filename)
        print("저장:", destination)
        upload.save(destination)
        json_data = auto_label(destination)
        save_json(destination, json_data)


    if is_ajax:
        return ajax_response(True, upload_key)
    else:
        return redirect(url_for("upload_complete", uuid=upload_key))

@app.route("/files/<uuid>")
def upload_complete(uuid):
    """The location we send them to at the end of the upload."""

    # Get their files.
    root = "static/images/{}".format(uuid)
    if not os.path.isdir(root):
        return "Error: UUID not found!"

    files = []
    for file in glob.glob("{}/*.*".format(root)):
        fname = file.split(os.sep)[-1]
        files.append(fname)

    return render_template("files.html",
        uuid=uuid,
        files=files,
    )

@app.route('/')
def index():
    return render_template("index.html", labels=Lables)

# return length of files
@app.route('/fileLength', methods=['POST'])
def fileLength():
    load_files()    
    files_info = dict()
    files_info["files_num"] = len(app.config["FILES"])
    files_info["head"] = 0

    return jsonify(result = "success", result2 = files_info)

# return image and labels data
@app.route('/loadImage', methods=['POST'])
def loadImage():
    index = int(request.json['index']) - 1
    image_data = dict()
    try:
        image_data['path'] = app.config["FILES"][index]
        image_data['labels'] = load_labels(image_data['path'])
    except:
        print("index error - " + str(request.json['index']) + ':' + str(len(app.config["FILES"])))
    
    return jsonify(result = "success", result2 = image_data)

@app.route('/loadLabels', methods=['POST'])
def loadLabels():
    index = int(request.json['index']) - 1
    image_path = app.config["FILES"][index]
    labels = load_labels(image_path)

    return jsonify(result = "success", result2 = labels)

@app.route('/addLabel', methods=['POST'])
def addLabel():
    index = int(request.json['index']) - 1
    label = request.json['label']

    image_path = app.config["FILES"][index]
    json_data = load_json(image_path)
    json_data['boxes'].append(label)
    
    save_json(image_path, json_data)

    return jsonify(result = "success")

@app.route('/removeLabel', methods=['POST'])
def removeLabel():
    index = int(request.json['index']) - 1
    labelIndex = request.json['labelIndex']

    image_path = app.config["FILES"][index]
    json_data = load_json(image_path)
    del json_data['boxes'][labelIndex]

    save_json(image_path, json_data)
    
    return jsonify(result = "success")

@app.route('/verifyImage', methods=['POST'])
def verifyImage():
    index = int(request.json['index']) - 1

    image_path = app.config["FILES"][index]
    json_data = load_json(image_path)

    json_data['verification'] = True

    save_json(image_path, json_data)

    return jsonify(result = "success")

@app.route('/register', methods=['POST'])
def register():
    print("register")

@app.route('/login', methods=['POST'])
def login():
    print("login")

# setup flask app config
if __name__ == "__main__":
    directory = "static/images/"
    app.config["IMAGES_DIR"] = directory
    app.config["LABELS"] = []

    load_files()

    app.run(host='0.0.0.0', port=5000, threaded=True)