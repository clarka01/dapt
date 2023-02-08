import sys, os
import numpy
import pandas as pd
import pdb

LOCAL_REPOSITORY_LOCATION = os.environ['LOCAL_REPOSITORY_LOCATION']

sys.path.append(f'{LOCAL_REPOSITORY_LOCATION}/pythonlib2')


from test_lib import test_utils as tu
from azure_lib import azure_utils as au

CONNECTION_STRING = os.getenv('AzureWebJobsStorage')

def test_read_df_from_blob_csv ():

    expected_df = pd.DataFrame(
        {
            'an_int': [1, 2, 3],
            'a_string': ['aa', 'bb', 'cc'],
        }
    )

    df_from_blob = au.read_df_from_blob_csv(
        containerName = 'test-container',
        blobName = 'pythonlib2/azure_lib/read_df_from_blob_csv.csv',
        delimiter = ','
    )
    
    assert (expected_df==df_from_blob).all().all()



def test_write_df_to_blob_csv():
    """
    This function tests two functions, write_df_to_blob_csv
    as well as read_df_from_blob_csv.  
    """ 
    sample_data = tu.generate_test_df()

    au.write_df_to_blob_csv(sample_data, 
        'test-container',
        'test_blob.csv',
        connection_str = CONNECTION_STRING
    )
    
    df = au.read_df_from_blob_csv(
        'test-container', 
        'test_blob.csv',
        ','
    )
    
    assert numpy.isclose(sample_data, df).all().all()


# def test_write_large_file_to_blob():
#     sample_data = tu.generate_large_test_df()

#     sample_data_csv = sample_data.to_csv(
#         encoding = "utf8",
#         sep=",", 
#         index=None, 
#         header=True
#     )

#     au.write_large_file_to_blob(sample_data_csv, 
#         'test-container',
#         'test_blob.csv',
#         connection_str = CONNECTION_STRING
#     )

#     df = au.read_df_from_blob_csv(
#         'test-container', 
#         'test_blob.csv',
#         ','
#     )
    
#     assert numpy.isclose(sample_data, df).all().all()




#move build_file_path_for_blob to ie_2

