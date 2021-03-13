# RobotChef
Recipe extractor using machine learning

#Why?
바쁜 현대인은 가지고 있는 재료를 일일히 보면서 레시피를 찾기 힘듭니다.

그래서 저희는 딥러닝을 이용해 재료를 파악하고 그것들과 연관된 레시피를 쉽게 추천해줍니다.

# datasets

1. youtube에서 클래스별로 검색해서 얻은 영상을 저장 - 영상제작자들의 자체 편집 및 다양한 구도의 이미지를 얻을 수 있어서 구글에서 이미지를 다운 받는 것 보다 훨씬 좋다고 생각됨(나중에 비교해보겠음)
2. 프레임별로 분리해서 원하는 프레임에 라벨링
3. 라벨링된 이미지를 해상도를 1:1로 만든다.
4. 7:3 비율로 학습 데이터를 나누어서 학습시킨다.

# train with darknet
AlexeyAB의 darknet [프레임워크](https://github.com/AlexeyAB/darknet)를 사용하여 yolov4 모델로 학습하였습니다.

과정을 간단히 정리하자면 다음과 같습니다.

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
