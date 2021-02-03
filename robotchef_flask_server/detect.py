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
from flask import Flask, request, Response, jsonify, render_template
import jsonpickle
#import binascii
import io as StringIO
import base64
from io import BytesIO
import io
import json
from PIL import Image

confthres = 0.3
nmsthres = 0.1
yolo_path = './'

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
                boxes.append([x, y, int(width), int(height)])
                confidences.append(float(confidence))
                classIDs.append(classID)

                    # apply non-maxima suppression to suppress weak, overlapping bounding
    # boxes
    idxs = cv2.dnn.NMSBoxes(boxes, confidences, confthres,
                            nmsthres)

    detected_obj_list = list()


    import copy
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

            rect['x'] = boxes[i][0]
            rect['y'] = boxes[i][1]
            rect['w'] = boxes[i][2]
            rect['h'] = boxes[i][3]

            obj['rect'] = rect
            obj['detectedClass'] = LABELS[classIDs[i]]
            obj['confidenceInClass'] = confidences[i]

            # 바운딩 박스 컬러 지정
            # 정해진 시드에서 미리 초기화하기 때문에 동일한 객체에 늘 같은 색깔 지정
            color = [int(c) for c in COLORS[classIDs[i]]]
            obj['color'] = color

            detected_obj_list.append(obj)

            # extract the bounding box coordinates
            (x, y) = (boxes[i][0], boxes[i][1])
            (w, h) = (boxes[i][2], boxes[i][3])

            # draw a bounding box rectangle and label on the image
            cv2.rectangle(image, (x, y), (x + w, y + h), color, 2)
            text = "{}: {:.4f}".format(LABELS[classIDs[i]], confidences[i])
            cv2.putText(image, text, (x, y - 5), cv2.FONT_HERSHEY_SIMPLEX,0.5, color, 2)

            print(boxes[i])
            print(classIDs[i])
            print(text)
    
    return image, detected_obj_list

labelsPath="darknet/data/obj.names"
cfgpath="darknet/cfg/yolov4-custom.cfg"
wpath="darknet/weight/yolov4-custom_best.weights"
Lables=get_labels(labelsPath)
CFG=get_config(cfgpath)
Weights=get_weights(wpath)
nets=load_model(CFG,Weights)
nets.setPreferableBackend(cv2.dnn.DNN_BACKEND_CUDA)
nets.setPreferableTarget(cv2.dnn.DNN_TARGET_CUDA)
Colors=get_colors(Lables)
# Initialize the Flask application
app = Flask(__name__)

@app.route('/')
def index():
    return render_template('streaming.html')

@app.route('/detect', methods=['POST'])
def detect():
    img = request.files['image']

    image = cv2.imdecode(np.fromstring(img.read(),np.uint8), cv2.IMREAD_UNCHANGED)
    result_image, obj_list = get_predection(image, nets, Lables, Colors)
    # cv2.imwrite('test.jpg', result_image)
    W, H = result_image.shape[:2]

    return jsonify({'data' : obj_list, 'width' : W, 'height' : H})

# start flask app
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')