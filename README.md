# RobotChef
Recipe extractor using machine learning

# train with darknet

darknet.exe detector train data/obj.data cfg/yolov4-custom.cfg yolov4.conv.137 -clear -map

1. obj.data : 학습할 데이터셋에 대한 세팅 파일
2. yolov4-custom.cfg : yolov4 신경망 구성 세팅 파일
3. yolov4.conv.137 : coco 데이터셋으로 pre-trained된 yolov4


# Client
1. Flutter로 구현한 어플 Http 통신으로는 Dio 플러그인 사용

# Servers

로그인서버: Appwrite(Docker) - Flask로 옮길지 고민중

검색서버: ElasticSearch(Docker)

YOLOv4 object detect server: Flask + Opencv 4.4.0(Cuda)로 구성한 서버

# TODO-list
1. 데이터 훈련 자동화
현재 모여진 데이터로는 객체 인식이 되지만 아직 부족한 듯 하다 이것을 해결하기 위하여
웹사이트에서 이미지를 라벨링을 하면 자동적으로 그 데이터를 가지고 훈련하는 아키텍처를 구상중이다.

서버는 Flask로 구현하여 GPU를 사용할 수 있게한다.

이미지 하나를 라벨링하면 10개로 Augmentation을 하여 7:3의 비율로 train, valid set을 나눌 예정

2. 어플 꾸미기?
