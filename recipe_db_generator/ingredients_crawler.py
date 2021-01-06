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

    keyword_list = [data['name'] for data in json_data]
    return keyword_list

def crawl_images():
    keyword_list = get_top_ingredients()

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
    dir_path = "..\\ingredient_detector\\darknet\\data\\img\\original\\"
    response = google_images_download.googleimagesdownload()

    arguments = {"keywords" : keyword,
                 "limit" : 400,
                 "silent_mode" : True,
                 "type" : "photo",
                 "thumbnail_only" : True,
                 "output_directory" : dir_path,
                 "chromedriver" : "./chromedriver"}
    response.download(arguments)

    # 이름 바꾸기
    rename_multiple_files(dir_path + keyword + '\\', keyword + '_')

    # 이미지 리사이즈
    # 사이즈는 32의 배수로 해야할 거임
    resized_img_dir_path = "..\\ingredient_detector\\darknet\\data\\img\\resized\\" + keyword + '\\'
    resize_multiple_images(dir_path + keyword + '\\', resized_img_dir_path, 512)
    
    # 세트 나누기
    split_img_dir_path = "..\\ingredient_detector\\darknet\\data\\img\\"
    split_images(resized_img_dir_path, split_img_dir_path)

if __name__ == '__main__':
    crawl_images()
