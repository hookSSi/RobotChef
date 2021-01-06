import time
import tqdm
import json
import numpy as np
import gc
from multiprocessing import Pool
from elasticsearch import Elasticsearch
from google_images_download import google_images_download

# elasticsearch에서 얻어온 재료 키워드 리스트를 사용해
# 구글 이미지에 검색 후 이미지를 크롤링한다.

es = Elasticsearch('localhost:9200')

# 가장 많이 쓰인 재료 리스트 반환
def get_top_ingredients(range=300):
    index = "recipe"
    body ="""
    {
      "size": 0,
      "aggs": 
      {
        "total_invoices": 
        {
          "terms": 
            {
            "field": "ingredients.name.keyword",
            "size": %d
            }
        }
      }
    }
    """ % range

    res = es.search(index=index, body=body)
    res = res['aggregations']['total_invoices']['buckets']
    return res

def insert_data_list():
    json_file_name = "recipe.json"
    json_data = None
    with open(json_file_name, 'r', encoding='UTF-8-sig') as json_file:
        json_data = json.load(json_file)

    # 각 ingredients 리스트 합쳐서 하나의 리스트로 만듬
    ingredient_list = list()
    for data in json_data:
        ingredient_list.extend(data["ingredients"]) 

    json_data = remove_dupe_dicts(ingredient_list, 'name')

    with open("ingredients.json", "w", encoding='UTF-8-sig') as json_file:
        json.dump(json_data, json_file, ensure_ascii = False, indent = 4)

    tasks = json_data
    pool = Pool(processes = 8)
    for _ in tqdm.tqdm(pool.imap_unordered(insert_data, tasks), total=len(tasks)):
        pass

def insert_data(doc):
    index = "ingredients(en)"
    es.index(index=index, doc_type="_doc", body=doc)

def read_dataset(file_name):
    saved_npz = np.load("./" + file_name, allow_pickle=True)
    # key = ingredients, recipes

    json_data = list()

    for idx, ingredient in enumerate(saved_npz['ingredients'], 1):
        json_data.append({'id' : idx, 'name' : ingredient})

    with open("ingredients(en).json", "w", encoding='UTF-8-sig') as json_file:
        json.dump(json_data, json_file, ensure_ascii = False, indent = 4)

    tasks = json_data
    pool = Pool(processes = 8)
    for _ in tqdm.tqdm(pool.imap_unordered(insert_data, tasks), total=len(tasks)):
        pass

def crawl_images(json_file_name):
    image_folder_name = "./Images/"
    category_name = "Ingredients/"

    json_data = None
    with open(json_file_name, 'r', encoding='UTF-8-sig') as json_file:
        json_data = json.load(json_file)

    keyword_list = [data['name'] for data in json_data]

    saved_idx = 0
    for idx in range(376, len(keyword_list), 8):
        download_images(keyword_list[idx:idx+8])
        print("%d : %d" % (idx, idx + 8))
        print("끝")
        saved_idx = idx
        time.sleep(1)

def download_images(keyword_list):
    tasks = keyword_list
    pool = Pool(processes = 8)
    pool.imap_unordered(download_image, tasks)
    pool.close()
    pool.join()

def download_image(keyword):
    response = google_images_download.googleimagesdownload()

    arguments = {"keywords" : keyword,
                 "limit" : 400,
                 "silent_mode" : True,
                 "type" : "photo",
                 "thumbnail_only" : True,
                 "chromedriver" : "./chromedriver"}

    response.download(arguments)
    del response
    gc.collect()

def get_ingredient_count(src):
    json_file_name = src
    json_data = None
    with open(json_file_name, 'r', encoding='UTF-8-sig') as json_file:
        json_data = json.load(json_file)

    # 각 ingredients 리스트 합쳐서 하나의 리스트로 만듬
    ingredient_list = list()
    for data in json_data:
        ingredient_list.extend(data["ingredients"]) 

    temp_dict = dict()
    for ingredient in ingredient_list:
        temp_dict[ingredient]


if __name__ == '__main__':
    #crawl_images("ingredients(en).json")
    get_top_ingredients()
    
