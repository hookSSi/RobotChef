import time
import requests
import tqdm
import json
import argparse
from multiprocessing import Pool, Manager
from elasticsearch import Elasticsearch
from datetime import datetime

# 레시피 json data를 elasticsearch 서버에 업로드한다.

# 레시피 이름 중복 제거
def remove_dupe_dicts(json_data):
    dup_check_dict = dict()
    new_json_data = list()

    for recipe in json_data:
        if not recipe['title'].strip() in dup_check_dict:
            new_recipe = dict(recipe)
            new_recipe['title'] = new_recipe['title'].strip()
            new_json_data.append(new_recipe)

            dup_check_dict[new_recipe['title']] = False
    
    return new_json_data

def insert_data_list(args):
    json_data = None
    with open(args.i, 'r', encoding='UTF-8-sig') as json_file:
        json_data = json.load(json_file)

    if args.rmd:
        print("중복 제거합니다.")
        json_data = remove_dupe_dicts(json_data) 

    tasks = json_data
    for task in tqdm.tqdm(tasks):
        insert_data(task, args)

def insert_data(doc, args):
    url = f"http://{args.user}:{args.p}@{args.url}:9200"
    es = Elasticsearch(url)
    index = args.ei
    es.index(index=index, doc_type="_doc", body=doc)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-user', type=str, required=True, help="elastic 서버 아이디")
    parser.add_argument('-p', type=str, required=True, help="elastic 서버 비밀번호")
    parser.add_argument('-url', type=str, required=True, help="elastic 서버 주소")
    parser.add_argument('-i', type=str, required=True, help="json 파일 path")
    parser.add_argument('-ei', type=str, required=True, help="elastic index 이름")
    parser.add_argument('-rmd', type=bool, help="레시피 타이틀 중복 삭제 여부")
    args = parser.parse_args()
    insert_data_list(args)

if __name__ == '__main__':
    main()