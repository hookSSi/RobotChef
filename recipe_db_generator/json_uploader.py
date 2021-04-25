import time
import requests
import tqdm
import json
from multiprocessing import Pool, Manager
from elasticsearch import Elasticsearch
from datetime import datetime

# 레시피 json을 elasticsearch 서버에 업로드한다.

es = Elasticsearch("http://username:password@robotchef.shop:9200")

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

def insert_data_list():
    json_file_name = "recipe.json"
    json_data = None
    with open(json_file_name, 'r', encoding='UTF-8-sig') as json_file:
        json_data = json.load(json_file)

    json_data = remove_dupe_dicts(json_data)

    tasks = json_data
    pool = Pool(processes = 8)
    for _ in tqdm.tqdm(pool.imap_unordered(insert_data, tasks), total=len(tasks)):
        pass

def insert_data(doc):
    index = "recipe-robotchef"
    es.index(index=index, doc_type="_doc", body=doc)

if __name__ == '__main__':
    insert_data_list()