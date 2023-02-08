import os
import sys
import pandas as pd
import pytest


local_repository_location = os.getenv('LOCAL_REPOSITORY_LOCATION')
sys.path.append(f'{local_repository_location}/pythonlib2')
CONNECTION_STRING = os.getenv('AzureWebJobsStorage')

# Load INTERNAL libraries
# =======================

from logging_lib import logging_utils as lu
from db_lib import sql_utils as sqlu
from azure_lib import azure_utils as au


# Add data
test_df = pd.DataFrame(
    {
        'an_int': [1, 2, 3],
        'a_string': ['aa', 'bb', 'cc'],
    }
)

au.write_df_to_blob_parquet(
    df = test_df,
    container_name='test-container',
    file_name='pythonlib2/azure_lib/read_df_from_blob_parquet.csv',
    
)