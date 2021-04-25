import os
import time
import json
import argparse
import requests
import re
from bs4 import BeautifulSoup
from elasticsearch import Elasticsearch

# 소스산업화센터에서 식재료 DB를 크롤링하는 코드
# 크롤링한 정보를 json으로 변환하여 elasticsearch에 업로드하도록 한다.

es = Elasticsearch('localhost:9200')

class Ingredient:
    def __init__(self, id, name, desc, synonyms):
        self.id = id
        self.name = name # 재료 이름
        self.desc = desc # 설명
        self.synonyms = synonyms # 동의어들

    def to_dic(self):
        return {
            'id' : self.id,
            'name' : self.name,
            'desc' : self.desc,
            'synonyms' : self.synonyms
        }
    
    def to_json(self):
        return json.dumps(self.to_dic())

    def print_info(self):
        print("======%s======" % self.name)
        print("id: %s\nname: %s \ndesc: %s \nsynonyms: %s" % (self.id, self.name, self.desc, self.synonyms))

def init(args):
    req = requests.get("https://sauce.foodpolis.kr/home/specialty/foodDbSearch.do")
    if req.status_code == 200:
        print("식재료 DB 정상 작동 크롤링을 시작합니다.")
        start_crawler(args)
    else:
        print("식재료 DB 접속 ERROR 인터넷 또는 호스트를 확인해주세요.")
        return False

def start_crawler(args):
    json_data = []
    # 현재 412페이지 까지 있음
    # 413페이지에서 전체 식재료가 표시되는 버그가 있으나 사용할지 말지는 모르겠음
    for index in range(1, 413):
        print("%d 페이지 재료들" % index)
        form_data = {
            'fdstfSnn' : '',
            'pageIndex' : index,
            'fdstfNm' : '',
            'PAGE_MN_ID' : 'SIS-030101'
        }
        req = requests.post("https://sauce.foodpolis.kr/home/specialty/foodDbSearch.do", form_data)
        soup = BeautifulSoup(req.content, 'html.parser')
        
        ingredients = soup.select('#content > div > div.conTableGroup.MAB30 > table > tbody > tr')
        for ingredient in ingredients:
            td_list = ingredient.select('td')
            id = td_list[0].get_text()

            name = td_list[1].get_text()

            # ？ 가 내용에 포함되는 문제가 있는데 
            # 규칙도 없어서 일일히 고쳐줘야할듯 '?' 랑은 다른 유니코드 기호임
            en_name = td_list[2].get_text().replace("(일명)", "") # (일명) 지우기
            en_name = [i.strip() for i in en_name.split(',')] # 쉼표로 구분한 배열화

            data_target = td_list[1].find('a').attrs['data-target']

            # 재료 설명 #myModal1 > div > div > div.modal-body > div.cont > dl:nth-child(1) > dd > p
            # 이명 #myModal1 > div > div > div.modal-body > div.cont > dl:nth-child(3) > dd
            desc = soup.select_one('%s > div > div > div.modal-body > div.cont > dl:nth-child(1) > dd' % data_target).get_text()
            synonyms = soup.select_one('%s > div > div > div.modal-body > div.cont > dl:nth-child(3) > dd' % data_target).get_text()
            synonyms = [i.strip() for i in synonyms.split(',')] + en_name
            synonyms = set(synonyms)
            synonyms = [name] + list(filter(None, synonyms))

            ingredient_obj = Ingredient(id, name, desc, synonyms)
            ingredient_obj.print_info()
            json_data.append(ingredient_obj.to_dic())
    path = create_json(args, json_data)

def create_json(args, json_data):
    dir = args.dir
    file_name = args.o

    if not os.path.isdir(dir):
        os.mkdir(dir)
    
    path = dir + '/' + file_name
    with open(path, 'w', encoding='UTF-8-sig') as f:
        json.dump(json_data, f, ensure_ascii = False, indent = 4)
        print(path)
        print("식재료 DB json 파일 저장 완료")

    return path

def create_synonyms_dict(args):
    dir = args.dir
    json_path = dir + '/' + args.i
    file_name = args.o

    json_data = []
    with open(json_path, 'r', encoding='UTF-8-sig') as f:
        json_data = json.load(f, encoding="utf-8")

    synonyms_dict = ""
    user_dict = ""
    for data in json_data:
        synonyms_dict += (','.join(data['synonyms']) + '\n')
        for name in data['synonyms']:
            hangul = re.compile(r'[ |가-힣]+')
            if hangul.match(name):
                ingredient_name = hangul.findall(name)[0].replace(' ', '')
                user_dict += ingredient_name + '\n'
                print(ingredient_name)
            
    # path = dir + '/' + file_name
    # with open(path, 'w', encoding='UTF-8-sig') as f:
    #     f.write(synonyms_dict)

    path = dir + '/(user)' + file_name
    with open(path, 'w', encoding='UTF-8-sig') as f:
        f.write(user_dict)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', type=str, help="동의어 사전을 만들기 위한 json 입력 파일 이름")
    parser.add_argument('-o', type=str, help="파일 출력 이름")
    parser.add_argument('-dir', type=str, required=True, help="읽거나 출력할 폴더 주소")
    args = parser.parse_args()

    if args.i == None:
        print("식재료 DB 크롤링")
        init(args)
    elif args.o is not None and args.i is not None:
        print("동의어 사전 만들기")
        create_synonyms_dict(args)
    else:
        print("argument ERROR -h 옵션을 참고하세요")

if __name__ == '__main__':
    main()

