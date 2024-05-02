import boto3
import botocore
import requests

proxies = {
   # 'https': 'http://proxy.example.com:8080',
}

sites = [
    { 'id':'site1', 'url':'https://leaf.qmonkey.co.uk/', 'timeout1':1, 'timeout2':5 },
    { 'id':'site2', 'url':'https://httpbin.org/delay/1', 'timeout1':1, 'timeout2':5 },
    { 'id':'site3', 'url':'https://httpbin.org/delay/6', 'timeout1':1, 'timeout2':5 },
    { 'id':'site4', 'url':'https://this.site.does.not.exist/', 'timeout1':1, 'timeout2':5 },
]

def lambda_handler(event, context):
   
   results = {}

   print('Pass 1')
   for site in sites:
       try:
           r = requests.head(site['url'],timeout=site['timeout1'],proxies=proxies)
           results[site['id']]=[site['url'],r.status_code,r.elapsed.total_seconds(),'pass1']
           print(site['id'],results[site['id']])
       except requests.exceptions.Timeout:
           print(site['id'],"timed out, will run in next pass")
       except Exception as e:
           results[site['id']]=[site['url'],0,r.elapsed.total_seconds(),'error',str(e)]
           print(site['id'],results[site['id']])

   print('Pass 2')
   for site in sites:
       if site['id'] in results :
           continue
       try:
           r = requests.head(site['url'],timeout=site['timeout2'],proxies=proxies)
           results[site['id']]=[site['url'],r.status_code,r.elapsed.total_seconds(),'pass2']
       except requests.exceptions.Timeout:
           results[site['id']]=[site['url'],0,r.elapsed.total_seconds(),'timed_out']
       except Exception as e:
           results[site['id']]=[site['url'],0,r.elapsed.total_seconds(),'error',str(e)]
       print(site['id'],results[site['id']])
   
   print('Results')    
   print(results)
   
   return results

