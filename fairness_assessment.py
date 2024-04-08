import csv
import json
import os

import requests

# Function to make a request and store the result
def make_request_and_store_result(pmcid, url, fuji_api_url, headers, results_folder):
    req_dict = {"object_identifier": url, "test_debug": True, "use_datacite": True}
    req = requests.post(fuji_api_url, json=req_dict, headers=headers)
    rs_json = req.json()
    res_filename = "{}.json".format(pmcid)
    res_filename_path = os.path.join(results_folder, res_filename)
    with open(res_filename_path, "w", encoding="utf-8") as fileo:
        json.dump(rs_json, fileo, ensure_ascii=False)

# Read from CSV and process
def process_csv(csv_file, fuji_api_url, headers, results_folder):
    with open(csv_file, 'r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            category = row['category']
            pmcid = row['pmcid']
            url = row['url']
            category_folder = os.path.join(results_folder, category)
            if not os.path.exists(category_folder):
                os.makedirs(category_folder)
            make_request_and_store_result(pmcid, url, fuji_api_url, headers, category_folder)

if __name__ == "__main__":
    fuji_api_url = "http://localhost:1071/fuji/api/v1/evaluate"
    headers = {
        "accept": "application/json",
        "Authorization": "Basic bWFydmVsOndvbmRlcndvbWFu",
        "Content-Type": "application/json",
    }
    results_folder = "./fairness_jsons/"

    csv_file = "./data/medical_fairness_urls.csv"

    process_csv(csv_file, fuji_api_url, headers, results_folder)
