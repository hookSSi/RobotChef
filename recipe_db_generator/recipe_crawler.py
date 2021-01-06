import time
import requests
import tqdm
import json
import pandas as pd
import os
from configobj import ConfigObj
from bs4 import BeautifulSoup
from multiprocessing import Pool, Manager
from PIL import Image
from pilkit.processors import Thumbnail

# 해먹남녀 사이트에서 유효한 레시피를 크롤링한다.

class Ingredient:
    def __init__(self, dic):
        self.recipe_id = dic['recipe_id'] # 레시피ID
        self.name = dic['name'] # 이름
        self.amount = dic['amount'] # 용량
    
class Instruction:
    def __init__(self, dic):
        self.recipe_id = dic['recipe_id'] # 레시피ID
        self.proc_num = dic['proc_num'] # 요리순번
        self.desc = dic['desc'] # 요리과정 설명
        self.image = dic['image'] # 요리과정 이미지

class Recipe:
    def __init__(self, dic):
        self.recipe_id = dic['recipe_id'] # 레시피ID
        self.title = dic['title'] # 레시피 제목
        self.image = dic['image']# 레시피 이미지
        self.sumry = dic['sumry'] # 레시피 간단 설명
        self.cooking_time = dic['cooking_time'] # 조리시간
        self.calorie = dic['calorie'] # 칼로리
        self.ingredients = [Ingredient(ingredient) for ingredient in dic['ingredients']] # 재료들
        self.instructions = [Instruction(instruction) for instruction in dic['instructions']] # 요리과정들
    def to_dic(self):
        dic = { 'recipe_id' : self.recipe_id,
                'title' : self.title,
                'image' : self.image, 
                'sumry' : self.sumry, 
                'cooking_time' : self.cooking_time,
                'calorie' : self.calorie,
                'ingredients' : [{ 'name' : ingredient.name,
                                   'amount' : ingredient.amount}
                                   for ingredient in self.ingredients],
                'instructions' : [{ 'proc_num' : instruction.proc_num,
                                    'desc' : instruction.desc,
                                    'image' : instruction.image}
                                    for instruction in self.instructions]}
        return dic
    def __repr__(self):
        return self.to_json()
    def to_dataframe(self):
        recipe_df = pd.DataFrame.from_dict({'recipe_id' : [self.recipe_id],
                                            'title' : [self.title],
                                            'image' : [self.image], 
                                            'sumry' : [self.sumry], 
                                            'cooking_time' : [self.cooking_time],
                                            'calorie' : [self.calorie]})

        ingredients_df = pd.DataFrame.from_dict({'recipe_id' : [item.recipe_id for item in self.ingredients],
                                                 'name' : [item.name for item in self.ingredients],
                                                 'amount' : [item.amount for item in self.ingredients]})

        instructions_df = pd.DataFrame.from_dict({'recipe_id' : [item.recipe_id for item in self.instructions],
                                                 'proc_num' : [item.proc_num for item in self.instructions],
                                                 'desc' : [item.desc for item in self.instructions],
                                                 'image' : [item.image for item in self.instructions]})
                                                 
        return { 'recipe' : recipe_df, 'ingredients' : ingredients_df, 'instructions' : instructions_df }

class RecipeCrawler:
    def __init__(self):
        # 해먹남녀에서 데이터를 크롤링함
        self.recipe_url = 'https://haemukja.com/recipes/'
        self.search_url = "https://haemukja.com/recipes?utf8=%E2%9C%93&sort=rlv&name="
        
        # 설정 파일 읽기
        self.config = ConfigObj("config.ini", create_empty=True)

        # 이미지 파일 저장 경로
        self.recipe_img_save_path = "C:/Users/HookSSi/Desktop/grad portfolio/recipe_db_generator/Images/Recipe/"
        self.instruction_img_save_path = "C:/Users/HookSSi/Desktop/grad portfolio/recipe_db_generator/Images/Instruction/"

        # 공유자원 리스트
        self.valid_id_list = list()
        self.recipe_list = list()

    def save_valid_recipe_id(self, valid_recipe_id_set):
        self.config['valid_id'] = valid_recipe_id_set
        self.config.write()
        print("유효한 레시피ID 목록 저장 완료")

    def search_valid_recipe_id(self, manager_list, start, end):
        self.valid_id_list = manager_list
        start_time = time.time()
        tasks = [idx for idx in range(start, end)]

        pool = Pool(processes = 8)
        for _ in tqdm.tqdm(pool.imap_unordered(self.get_valid_recipe_id, tasks), total=len(tasks)):
            pass

        print("탐색 범위 : {}~{}".format(start, end))
        print("실행 시간 : %s초" % (time.time() - start_time))
        print("레시피 갯수 : %d개" % len(self.valid_id_list))
        self.save_valid_recipe_id(sorted(self.valid_id_list)) # 레시피ID 리스트 저장

    def get_valid_recipe_id(self, idx):
        response = requests.get(self.recipe_url + str(idx))
        if response.status_code == 200:
            soup = BeautifulSoup(response.content, 'html.parser')
            alert_box = soup.select_one('#flash_notice')
            if alert_box == None:
                self.valid_id_list.append(idx)
        else:
            print("에러 : " + str(response.status_code))

    def launch_crawler(self, manager_list):
        print("크롤링 시작")

        # 유효한 레시피ID들 불러온다.
        valid_recipe_id_set = set([4, 37, 38, 39, 40, 41]) # 테스트 용 값
        if 'valid_id' in self.config:
            valid_recipe_id_set = self.config['valid_id']

        start_time = time.time()
        tasks = [idx for idx in valid_recipe_id_set]

        # 공유자원 할당
        self.recipe_list = manager_list
        pool = Pool(processes = 8)
        for _ in tqdm.tqdm(pool.imap_unordered(self.get_recipe, tasks), total=len(tasks)):
            pass
        print("실행 시간 : %s초" % (time.time() - start_time))

        # json 파일로 저장
        json_dumps = [recipe.to_dic() for recipe in self.recipe_list]

        with open("recipe.json", "w", encoding='UTF-8-sig') as json_file:
            json.dump(json_dumps, json_file, ensure_ascii = False, indent = 4)

    def get_recipe(self, recipe_id):
        response = requests.get(self.recipe_url + str(recipe_id))

        if response.status_code == 200:
            soup = BeautifulSoup(response.content, 'html.parser', from_encoding='utf-8')

            # 레시피
            recipe_title = soup.select_one('#container > div.inpage-recipe > div > div.view_recipe > section.sec_info > div > div.top > h1 > strong').get_text()
            recipe_image = self.get_recipe_thumb_url(recipe_title)
            #self.download_image(recipe_image, recipe_title + ".png")
            recipe_sumry = soup.select_one('#container > div.inpage-recipe > div > div.view_recipe > section.sec_info > div > div.top > h1').get_text()
            recipe_sumry = ''.join(recipe_sumry.split('\n')) # 개행 문자 제거
            recipe_sumry = ' '.join(recipe_sumry.split()) # 중복 공백 제거
            recipe_cooking_time = soup.select_one('#container > div.inpage-recipe > div > div.view_recipe > section.sec_info > div > div.top > dl > dd:nth-child(2)').get_text()
            recipe_calorie = soup.select_one('#container > div.inpage-recipe > div > div.view_recipe > section.sec_info > div > div.top > dl > dd:nth-child(6)')
            if recipe_calorie == None:
                recipe_calorie = "0 kcal"
            else:
                recipe_calorie = recipe_calorie.get_text()
            
            # 재료
            recipe_ingredients = soup.select_one('#container > div.inpage-recipe > div > div.view_recipe > section.sec_info > div > div.btm > ul').select('li')
            recipe_ingredients = [{'recipe_id' : recipe_id,
                                   'name' : ingredient.select_one('span').get_text(),
                                   'amount' : ingredient.select_one('em').get_text()}
                                   for ingredient in recipe_ingredients]
            #print(recipe_ingredients)
            # 요리 과정
            recipe_instructions = soup.select_one('#container > div.inpage-recipe > div > div.view_recipe > section.sec_detail > section.sec_rcp_step > ol').select('li')
            recipe_instructions = [{'recipe_id' : recipe_id,
                                    'proc_num' : idx,
                                    'image' : instruction.select_one('div > img').get('src'),
                                    'desc' : instruction.select_one('p').get_text('\n')}
                                    for idx, instruction in enumerate(recipe_instructions, 1)]
            #print(recipe_instructions)

            dic = {
                'recipe_id' : recipe_id,
                'title' : recipe_title,
                'image' : recipe_image,
                'sumry' : recipe_sumry,
                'cooking_time' : recipe_cooking_time,
                'calorie' : recipe_calorie,
                'ingredients' : recipe_ingredients,
                'instructions' : recipe_instructions
            }
            recipe_obj = Recipe(dic)
            self.recipe_list.append(recipe_obj)
            return True
        else:
            print(response.status_code)
            return False

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
        self.search_valid_recipe_id(0, 10)
        self.launch_crawler()
        #time.sleep(2)

if __name__ == '__main__':
    manager = Manager()
    recipe_list = manager.list()

    crawler = RecipeCrawler()
    crawler.launch_crawler(recipe_list)