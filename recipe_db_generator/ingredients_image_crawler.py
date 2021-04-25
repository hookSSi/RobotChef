import time
import json
import numpy as np
import gc
from multiprocessing import Pool
from elasticsearch import Elasticsearch
from google_images_download import google_images_download
from image_preprocess import *

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
    return [bucket['key'] for bucket in res]

# json 파일 읽기
def read_json_data(json_file_name):
    json_data = None
    with open(json_file_name, 'r', encoding='UTF-8-sig') as json_file:
        json_data = json.load(json_file)

    return json_data

# json 파일 읽기
def read_json_data(json_file_name):
    json_data = None
    with open(json_file_name, 'r', encoding='UTF-8-sig') as json_file:
        json_data = json.load(json_file)

    return json_data

# json 파일 읽기
def read_class_list(file_name):
    data_list = None
    with open(file_name, 'r', encoding='UTF-8-sig') as f:
        data_list = f.readlines()
    return [data.strip('\n') for data in data_list]

def crawl_images():
    #keyword_list = get_top_ingredients()
    keyword_list = read_class_list('class_list')

    saved_idx = 0
    for idx in range(0, len(keyword_list), 8):
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
    dir_path = "..\\OpenLabeling\\img\\"
    response = google_images_download.googleimagesdownload()
    
    key = keyword.split(',')[0]
    dir_name = keyword.split(',')[1].strip()

    arguments = {"keywords" : key,
                 "limit" : 60,
                 "silent_mode" : True,
                 "output_directory" : dir_path + dir_name,
                 "no_directory" : True,
                 "chromedriver" : "./chromedriver"}
    response.download(arguments)

if __name__ == '__main__':
    crawl_images()

    dir_path = "..\\OpenLabeling\\img\\"

    for filename in os.listdir(dir_path):
        if os.path.isdir(dir_path + filename):
            rename_multiple_files(dir_path + filename + '\\', filename + '_')

