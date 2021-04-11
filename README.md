RobotChef
==============================

딥러닝을 이용한 식재료 탐지 및 레시피 검색

1. [만드는 이유](#Why?)
2. [제공 서비스](#제공-서비스)
3. [요구사항](#요구사항)
4. [설치 및 실행](#설치-및-실행)
5. [RobotChef OD Server](#RobotChef-OD-Server)
    * [모델과 학습](#모델과-학습)
    * [객체 인식](#객체-인식)
6. [RobotChef App](#RobotChef-App)
    * [회원 관리](#회원-관리)
    * [레시피 검색](#레시피-검색)
    * [이미지 전송](#이미지-전송)

# Why?
누구나 인터넷을 통해 검색을 할 수 있는 시대에서도 냉장고 안에 한정된 재료들로 요리할 수 있는 음식을 찾는 것은 쉬운 일이 아닙니다.
 
냉장고의 재료들을 모두 꺼내어 재료들의 종류와 용량을 확인하여 레시피를 일일이 검색하여 재료들을 일일이 대조해봐야 하기 때문입니다.

냉장고의 재료들을 모두 꺼내어 보는 것은 어쩔 수 없다고 생각하지만 사용자들을 위해 프로그램이 자동으로 최적의 레시피를 찾기 쉽게 만들어 줄 수는 있다고 생각했습니다.
 
그래서 저희는 딥러닝을 이용해 이미지 속 재료를 파악하고 연관된 레시피를 쉽게 추천해줍니다.

# 제공 서비스
1. 레시피 검색
2. 레시피 즐겨찾기
3. 가장 중요한 이미지 속 **식재료 추출** 하여 검색

## Example

자취생인 A는 아침을 먹기 위해 요리 준비를 한다. 먼저 냉장고에서 먹을 재료들을 책상에 올린다. 재료들은 다음과 같다. “두부 1모, 양파 1개, 된장, 호박 1개” 그리고 A는 스마트폰을 꺼내어 RobotChef를 실행시킨 뒤 사진 촬영 옵션을 선택하여 재료들이 놓인 모습을 촬영한다. 프로그램이 분석을 끝내어 요리 재료와 연관성이 높은 레시피 목록들을 출력한다. A는 된장찌개를 해보고 싶은 생각이 들기 때문에 “된장” 으로 검색을 한다. 된장찌개의 레시피가 검색되어 해당 레시피를 선택하여 상세 요리 정보를 보며 요리한다. 그리고 레시피가 마음에 든 A는 레시피를 즐겨찾기에 등록한다.

# 요구사항

1. [ElasticSearch](https://github.com/elastic/elasticsearch)
2. [Appwrite](https://github.com/appwrite/appwrite)
3. Android Studio
4. Flutter
5. Python, opencv_python-4.5.1, Flask

# 설치 및 실행
1. project clone
2. ElasticSearch, Appwrite 서버 설치 및 실행
3. robotchef_flask_server\app.py 실행
4. robotchef_app를 안드로이드 스튜디오 프로젝트로 열기
5. 프로젝트를 실행 및 빌드  

# RobotChef OD Server

RobotChef의 식재료 탐지 딥러닝 모델은 AlexeyAB의 [darknet 프레임워크](https://github.com/AlexeyAB/darknet)를 사용하여 yolov4 모델로 학습하였습니다.

## 모델과 학습

훈련 과정을 간단히 정리하자면 다음과 같습니다.

**anchor 계산**

라벨링된 데이터들의 anchor box의 평균을 구합니다.

darknet.exe detector calc_anchors data/obj.data -num_of_clusters 9 -width 608 -height 608

1. obj.data : 학습할 데이터셋에 대한 세팅 파일

**학습**

학습 데이터를 사용해 학습을 합니다.

darknet.exe detector train data/obj.data cfg/yolov4-custom.cfg yolov4.conv.137 -clear -map

1. obj.data : 학습할 데이터셋에 대한 세팅 파일
2. yolov4-custom.cfg : yolov4 신경망 구성 세팅 파일
3. yolov4.conv.137 : coco 데이터셋으로 pre-trained된 yolov4

**mAP 측정**

객체 탐지에서 주로 사용되는 지표인 mAP(Mean average precision)를 측정하여 어느 정도 만족된다면 모델을 사용하고 만족하지 못한다면 다시 튜닝을 거쳐 학습합니다.

darknet.exe detector map data/obj.data cfg/yolov4-custom.cfg backup/yolov4-custom_best.weights

1. obj.data : 학습할 데이터셋에 대한 세팅 파일
2. yolov4-custom.cfg : yolov4 신경망 구성 세팅 파일
3. yolov4-custom_best.weights : 학습된 결과 weight 파일

## 객체 인식
서버 구축을 위한 Python 프레임워크인 Flask 사용하여 모델을 서버에 올린뒤 dnn을 지원하는 opencv_python-4.5.1을 사용하여 POST 요청으로 오는 이미지 파일을 입력으로 객체를 탐지합니다.

# RobotChef App
1. Flutter로 구현한 어플 Http 통신으로는 Dio 플러그인 사용

## 회원 관리
Docker에서 다양한 플랫폼을 위한 Open-Source backend 서버인 [Appwrite](https://github.com/appwrite/appwrite)를 설치하여 회원 관리로 사용하고 있습니다.

회원 관리의 주요 기능으로는 다음과 같습니다.

* 회원가입
* 로그인
* 레시피 즐겨찾기

## 레시피 검색
Docker에서 Open-Source 검색 엔진 중 하나인 [ElasticSearch](https://github.com/elastic/elasticsearch)를 설치하여 검색 서버 및 레시피 DB로 사용하고 있습니다.

레시피들에 대한 정보는 [해먹남녀](https://haemukja.com/)에서 크롤링하여 사용하고 있고 갯수는 4,617개 입니다.

## 이미지 전송
앱에서 카메라의 이미지를 실시간으로 전송하려면 Yuv 포멧을 Jpeg로 변환하여 할 필요가 있습니다. 

그래서 다음의 [오픈 소스 프로젝트](https://github.com/tomerblecher/YUV_2_RGB)에서 컨버터를 가져왔습니다.
