# RobotChef
Recipe extractor using machine learning

# train with darknet
AlexeyAB의 darknet [프레임워크](https://github.com/AlexeyAB/darknet)를 사용

**anchor 계산**

darknet.exe detector calc_anchors data/obj.data -num_of_clusters 9 -width 608 -height 608

1. obj.data : 학습할 데이터셋에 대한 세팅 파일

**학습**

darknet.exe detector train data/obj.data cfg/yolov4-custom.cfg yolov4.conv.137 -clear -map

1. obj.data : 학습할 데이터셋에 대한 세팅 파일
2. yolov4-custom.cfg : yolov4 신경망 구성 세팅 파일
3. yolov4.conv.137 : coco 데이터셋으로 pre-trained된 yolov4

**map 측정**

darknet.exe detector map data/obj.data cfg/yolov4-custom.cfg backup/yolov4-custom_best.weights

1. obj.data : 학습할 데이터셋에 대한 세팅 파일
2. yolov4-custom.cfg : yolov4 신경망 구성 세팅 파일
3. yolov4-custom_best.weights : 학습된 결과 weight 파일

# Client
1. Flutter로 구현한 어플 Http 통신으로는 Dio 플러그인 사용

# Servers

로그인서버: [Appwrite(Docker)](https://github.com/appwrite/appwrite)

검색서버: [ElasticSearch(Docker)](https://github.com/elastic/elasticsearch)

YOLOv4 object detect server: Flask + Opencv 4.4.0(Cuda)로 구성한 서버

# TODO-list
1. 데이터 훈련 자동화

2. 어플 버그 및 UI 개선

3. elasticsearch 동의어 사전 적용 ex) egg == 달걀, 계란
