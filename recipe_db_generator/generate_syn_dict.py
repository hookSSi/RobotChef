import requests
import urllib
import json
from bs4 import BeautifulSoup
from elasticsearch import Elasticsearch

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

def save_keyword_list():
    keyword_list = get_top_ingredients()
    with open('class_list', "w", encoding='UTF-8-sig') as f:
        for keyword in keyword_list:
            f.write(keyword + '\n')

def read_json(json_file_name):
    json_data = None
    with open(json_file_name, "r", encoding='UTF-8-sig') as json_file:
        json_data = json.load(json_file)
    return json_data

def search_dic(keyword):
    naver_dic_url = "https://dict.naver.com/search.nhn?dicQuery=" + keyword
    response = requests.get(naver_dic_url)
    print(naver_dic_url)
    
    if(response.status_code == 200):
        soup = BeautifulSoup(response.content, 'html.parser', from_encoding='utf-8')
        result = ""
        try:
            result += soup.select_one("#content > div.en_dic_section.search_result.dic_en_entry > dl > dd:nth-child(2)").get_text()
        except:
            result = "네이버 사전에 등재되어 있지 않습니다."
    return result.strip()
    
def generate_syn_dic(src, dst):
    json_data = read_json(src)

    with open(dst, "w", encoding='UTF-8-sig'):
        print("파일 생성")
    syn_dic_file = open(dst, "a", encoding='UTF-8-sig')
    for data in json_data:
        en = search_dic(data['name'])
        if en is not "네이버 사전에 등재되어 있지 않습니다.":
            syn_dic_file.write(data['name'] + ', ' + en + '\n')
            print("결과: " + en)
        else:
            print("결과: 실패")
    syn_dic_file.close()

if __name__ == '__main__':
    #generate_syn_dic("ingredients(kr).json", "syn_dict.dic")
    save_keyword_list()