import io
import pandas as pd
import requests
import os
import glob
import json
if 'data_loader' not in globals():
    from mage_ai.data_preparation.decorators import data_loader
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test

# Read Kaggle json
f = open('/home/src/kaggle.json')
data = json.load(f)
os.environ['KAGGLE_USERNAME'] = data['username'] # username from the json file
os.environ['KAGGLE_KEY'] = data['key'] # key from the json file
import kaggle

@data_loader
def load_data_from_api(*args, **kwargs):
    """
    Template for loading data from API
    """
    dataset_name = 'divaniazzahra/mental-health-dataset'
    out_path ='home/data/mental_health_dataset/'
    kaggle.api.dataset_download_files(dataset_name, path=out_path, unzip=True)

    out_file = glob.glob(out_path + '*')

    data_types = {
        'Gender': str,
        'Country': str,
        'Occupation'
        'self_employed': str,
        'family_history': str,
        'treatment': str,
        'Days_Indoors': str,
        'Growing_Stress': str,
        'Changes_Habits': str,
        'Mental_Health_History': str,
        'Mood_Swings': str,
        'Coping_Struggles': str,
        'Work_Interest': str,
        'Social_Weakness': str,
        'mental_health_interview': str,
        'care_options': str,
    }

    parse_dates = ['Timestamp']

    df = pd.read_csv(out_file[0], sep = ',', dtype=data_types, parse_dates=parse_dates)

    #df = pd.read_csv(out_file[0], sep = ',', dtype=data_types)

    # Remove locally downloaded file. It is not needed anymore
    os.remove(out_file[0])

    return df



@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output is not None, 'The output is undefined'
