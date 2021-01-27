# RobotChef
Recipe extractor using machine learning

# TODO-list
1. 데이터 훈련 자동화
현재 모여진 데이터로는 객체 인식이 되지만 아직 부족한 듯 하다 이것을 해결하기 위하여
웹사이트에서 이미지를 라벨링을 하면 자동적으로 그 데이터를 가지고 훈련하는 아키텍처를 구상중이다.

서버는 Flask로 구현하여 GPU를 사용할 수 있게한다.

이미지 하나를 라벨링하면 10개로 Augmentation을 하여 7:3의 비율로 train, valid set을 나눌 예정

2. 어플 꾸미기?
