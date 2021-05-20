import time
import requests
import tqdm
import json
import pandas as pd
import os
from configobj import ConfigObj
from bs4 import BeautifulSoup
from PIL import Image
from pilkit.processors import Thumbnail
import xmltodict
import re
import argparse


parser = argparse.ArgumentParser(description='make json to upload elastic from recipe api')
parser.add_argument('--startIdx', type=int, help='start index')
parser.add_argument('--endIdx', type=int, help='end index')
parser.add_argument('--update', type=bool, help='update from api? or just use json in local?')

# 식품의약품안전처에서 조리식품의 레시피 DB를 가져옴
class RecipeLoader:
    def __init__(self):
        # 설정 파일 읽기
        self.config = ConfigObj("config.ini", create_empty=True)

        self.keyId = self.config['KEY']['AUTH_KEY']  # 인증키
        self.serviceId = "COOKRCP01" # 서비스명
        self.dataType = "xml" # 요청파일 타입
        self.startIdx = 1 # 요청 시작 위치
        self.endIdx = 1400 # 요청 종료 위치
        self.fileIdx = 1

        self.recipe_url = f"http://openapi.foodsafetykorea.go.kr/api/{self.keyId}/{self.serviceId}/{self.dataType}/{self.startIdx}/{self.endIdx}"

        # 이미지 파일 저장 경로
        self.img_save_path = self.config['PATH']['IMG_PATH']

        # 레시피 json 파일 저장 경로
        self.recipe_json_save_path = self.config['PATH']['JSON_PATH']

    # 레시피 DB를 새로 받아서 json으로 저장
    def update_recipe_db(self):
        print(self.img_save_path)
        
        for idx in range(self.startIdx, self.endIdx, 10):
            self.recipe_url = f"http://openapi.foodsafetykorea.go.kr/api/{self.keyId}/{self.serviceId}/{self.dataType}/{idx}/{idx+9}"
            print(self.recipe_url)
            response = requests.get(self.recipe_url)
            tree = xmltodict.parse(response.content)

            result = tree[self.serviceId]['RESULT']

            if result['CODE'] == 'INFO-000':
                self.save_json(tree, self.recipe_json_save_path, self.fileIdx)
                self.fileIdx += 1
            else:
                print("에러 발생 ")
                print(f"에러 코드: {result['CODE']}")
                break

    def get_recipes(self):
        recipe_data_list = list()
        self.fileIdx = len(os.listdir(self.recipe_json_save_path)) + 1
        for idx in range(1, self.fileIdx):
            print(f"\n{idx}번째 json 처리 중...")
            recipe_data_list.extend(self.get_recipe(idx))
        self.save_json(recipe_data_list, "./")

    # 저장된 레시피 DB json 객체를 사용하여
    # 필요한 정보만 가지는 json으로 변환하는 전처리 과정 
    def get_recipe(self, idx):
        tree = self.load_json(self.recipe_json_save_path, idx)
        recipe_rows = tree[self.serviceId]['row']

        recipe_data_list = list()
        
        for row in recipe_rows:
            recipe_data = dict()
            recipe_data["recipe_id"] = row['RCP_SEQ'] # 레시피ID
            recipe_data["title"] = row['RCP_NM'] # 레시피 이름
            recipe_data["image"] = row['ATT_FILE_NO_MK']# 레시피 이미지

            print(f"{ recipe_data['title'] } 처리 중...")

            # 간단 레시피 소개
            sumry = f"{row['HASH_TAG'] or ','},\
                      {row['RCP_PAT2'] or ''},\
                      {row['RCP_WAY2'] or ''}"
            sumry = sumry.replace('  ', '')
            sumry = sumry.replace(',,', '')
            sumry = sumry.replace(',', ', ')
            recipe_data["sumry"] = sumry
            
            recipe_data["info_eng"] = row['INFO_ENG'] # 열량
            recipe_data["info_car"] = row['INFO_CAR'] # 탄수화물
            recipe_data["info_pro"] = row['INFO_PRO'] # 단백질
            recipe_data["info_fat"] = row['INFO_FAT'] # 지방
            recipe_data["info_na"] = row['INFO_NA'] # 나트륨

            # 요리 재료 리스트 만듬
            recipe_data['ingredients'] = list()
            if row['RCP_PARTS_DTLS'] is not None:
                ingredients_data = ', '.join(row['RCP_PARTS_DTLS'].split('\n'))
                ingredients_data = re.split(r"(, )(?=[가-힣])", ingredients_data)
                ingredients_data = list(map(lambda x: x.strip(), ingredients_data))
                ingredients_data = list(filter(lambda x: x != '', ingredients_data))
                ingredients_data = list(filter(lambda x: x != ',', ingredients_data))

                for data in ingredients_data:

                    p = re.compile(r"([(0-9.]+)\s*([a-zA-Z)]+)")
                    m = p.search(data)

                    ingredient = {
                        'name' : "",
                        'amount' : ""
                    }
                    
                    if m:
                        ingredient['name'] = data[:m.start()].strip()
                        ingredient['amount'] = ''.join(filter(lambda x: x != '(' and x != ')', m.group())) 
                    else:
                        ingredient['name'] = data.strip()

                    # 레시피 데이터에 재료 그룹 추가
                    recipe_data['ingredients'].append(ingredient)
            
            # 요리 순서 리스트 만듬
            instruct_list = list()
            for index in range(1, 21):
                desc = row[f'MANUAL{str(index).zfill(2)}']
                if desc is not None: 
                    instruct = {
                        'proc_num' : index,
                        'desc' : desc,
                        'image' : row[f'MANUAL_IMG{str(index).zfill(2)}'] or None
                    }
                    instruct_list.append(instruct)
                else:
                    break
            recipe_data['instructions'] = instruct_list
            recipe_data_list.append(recipe_data)

        return recipe_data_list

    def save_json(self, json_data, path, idx = None):
        self.create_directory(path)

        if idx is not None:
            file_path = os.path.join(path, f'recipe_{idx}.json')
        else:
            file_path = os.path.join(path, f'recipe.json')

        with open(file_path, 'w', encoding='UTF-8-sig') as f:
            json.dump(json_data, f, ensure_ascii = False, indent = 4)
            print(file_path)
            print("식재료 DB json 파일 저장 완료")

    def load_json(self, path, idx):
        file_path = os.path.join(path, f'recipe_{idx}.json')
        with open(file_path, 'r', encoding='UTF-8-sig') as f:
            return json.load(f)
        
    def create_directory(self, path):
        try:
            if not os.path.isdir(path):
                os.mkdir(path)
                print(f"폴더 생성 완료: {path}")
        except:
            print("폴더 생성 실패")

    def get_recipe_thumb_url(self, title):
        response = requests.get(self.search_url + title)
        image_url = ""
        if response.status_code == 200:
            soup = BeautifulSoup(response.content, 'html.parser', from_encoding='utf-8')
            image_url = soup.select_one('#content > section > div.recipes > div > ul > li:nth-child(1) > a > img').get('src')
        return image_url

    def download_image(self, image_url, file_name):
        pic = requests.get(image_url)

        if pic.status_code == 200:
            if not os.path.isdir(self.recipe_img_save_path):
                os.mkdir(self.recipe_img_save_path)
            with open(self.recipe_img_save_path + file_name.replace('/', '-'), 'wb') as photo:
                photo.write(pic.content)

    def run(self):
        self.create_directory('Recipe')
        self.update_recipe_db()
        self.get_recipes()

if __name__ == '__main__':
    recipe_loader = RecipeLoader()
    recipe_loader.run()