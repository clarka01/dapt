# Pushing Changes 
import sys
import logging
import os
import io
import pandas as pd
import pdb
import pyarrow as pa
import pyarrow.parquet as pq
from azure.storage.blob import BlobServiceClient, BlobClient,  \
    ContentSettings, __version__

# Add location of own packages to path 
# ====================================
try:
    LOCAL_REPOSITORY_LOCATION = os.environ['LOCAL_REPOSITORY_LOCATION']

    sys.path.append(f'{LOCAL_REPOSITORY_LOCATION}/pythonlib2')

except:
    pass


# Load INTERNAL libraries
# =======================
from hbb_lib import basic_utils as bu
from date_lib_hbb import date_utils_hbb as du


#connection string (found in Azure) for storage account is stored in env var
CONNECTION_STRING=""
CONNECTION_STRING = os.getenv('AzureWebJobsStorage')
if (CONNECTION_STRING == None):
    CONNECTION_STRING = os.getenv("AZURE_STORAGE_CONNECTION_STRING")
else:
    print("Please set the AZURE_STORAGE_CONNECTION_STRING before using the BLOB functions")


# Write to blob
# =============

def source_file_name(local_path_file):
    ret_value = 0
    if os.path.exists(local_path_file) and os.path.getsize(local_path_file) > 0:
        ret_value = 0
    else:
        print("File " , local_path_file, " does not exists")
        ret_value = 1
    return ret_value

def build_az_blob_command_line(azure_acount_name, azure_container_name ,local_file_path_name, blob_name):
    
    if (source_file_name(local_file_path_name) == 0):
        account_storage_string = os.getenv("AZURE_ACCOUNT_STORAGE_KEY")
        print(account_storage_string)
    
        command = """az storage blob upload """  + \
                  """ --account-name """ + azure_acount_name + \
                  """ --container-name """ + azure_container_name + \
                  """ --account-key """ + account_storage_string + \
                  """   --file  """ + local_file_path_name + \
                  """ --name """ + blob_name
#        print(command)        
        os.system(command)    
    else:
        print("File " , local_file_path_name, " does not exists")

def write_to_blob (
    file, 
    container_name, 
    file_name, 
    connection_str = CONNECTION_STRING, 
    blob_type = 'BlockBlob'
):
    """
    file: (come back to this) convert to csv, etc (no dataframes)
    """
    # if not isinstance(file, str): 
    #     raise TypeError ('Data type not string.')
    blob_type_map = {'BlockBlob':True,
                     'AppendBlob':False}
    # Instantiate a new BlobServiceClient using a connection string
    blob_service_client = BlobServiceClient.from_connection_string(connection_str)
    # Set content settings to include utf-8 encoding for Excel
    cnt_settings = ContentSettings(content_encoding = 'utf-8')
    # Instantiate a new ContainerClient
    container_client = blob_service_client.get_container_client(container_name)
    # Instantiate a new BlobClient
    blob_client = container_client.get_blob_client(file_name)
    # upload data
    blob_client.upload_blob(
        file, 
        blob_type=blob_type,
        content_settings = cnt_settings,
        overwrite=blob_type_map[blob_type]
    )


def write_df_to_blob_csv(
    df, 
    container_name, 
    file_name, 
    delimiter = ",",
    connection_str = CONNECTION_STRING,
    blob_type= 'BlockBlob', 
    header=True
):
    csv_ = df.to_csv(
        encoding = "utf8",
        sep=delimiter, 
        index=None, 
        header=header
    )

    write_to_blob(
        file = csv_,
        container_name = container_name,
        file_name = file_name,
        connection_str = connection_str,
        blob_type=blob_type
    )


def write_df_to_blob_parquet(
    df, 
    container_name, 
    file_name, 
    connection_str = CONNECTION_STRING, 
    blob_type = 'BlockBlob'
):
    parquet_table = pa.Table.from_pandas(df)
    buffer_ = pa.BufferOutputStream()
    pq.write_table(parquet_table, buffer_,)
    write_to_blob(
        file = buffer_.getvalue().to_pybytes(),
        container_name = container_name,
        file_name = file_name,
        connection_str = connection_str,
        blob_type=blob_type
    )


# Read blob
# =========

def read_blob(containerName, blobName,connection_str = CONNECTION_STRING ):

    """
    Parameters
    ----------
        containerNamer: str
        blobName: str
    Returns
    -------
        blobStream
    """
    
    blob = BlobClient.from_connection_string(
        conn_str=connection_str,
        container_name=containerName,
        blob_name=blobName
    )

    blobStream = blob.download_blob().content_as_bytes() 
    logging.debug('blobStream downloaded') 

    return blobStream


def read_df_from_blob_csv (containerName, blobName, delimiter,connection_str = CONNECTION_STRING):
    """
    Parameters
    ----------
        containerNamer: str
        blobName: str
        delimiter: str (most likely ',' unless your csv is delimited otherwise)
    Returns
    -------
        df: pandas dataFrame
    """
    blobStream = read_blob(containerName, blobName,connection_str=connection_str)

    df = pd.read_csv(
        io.BytesIO(blobStream), 
        delimiter=delimiter
    )
        
    return df


def read_df_from_blob_parquet (containerName, blobName):
    """
    Parameters
    ----------
        containerNamer: str
        blobName: str
    Returns
    -------
        df: pandas dataFrame
    """
    blobStream = read_blob(containerName, blobName)
    df = pq.to_table(
        io.BytesIO(blobStream)
    ) \
    .to_pandas()
        
    return df



"""
write_large_file_to_blob breaks at 'with open' statement
ignored in test_azure_utils.py
"""
# def write_large_file_to_blob(
#     data, 
#     container_name, 
#     file_name, 
#     connection_str 
# ):
#      # Set content settings to include utf-8 encoding for Excel
#     cnt_settings = ContentSettings(content_encoding = 'utf-8')

#     blob_client = BlobClient.from_connection_string(
#         connection_str,
#         container_name,
#         file_name
#     )
    
#     #upload 4 MB for each request
#     chunk_size=4*1024*1024  

#     if(blob_client.exists):
#         blob_client.create_append_blob()

#     with open(data_loc, "rb") as stream:
#         while True:
#             read_data = stream.read(chunk_size)
            
#             if not read_data:
#                 print('uploaded')
#                 break 
#             blob_client.append_block(read_data)
    
#     blob_client.upload_blob(
#         data, 
#         blob_type="BlockBlob",
#         content_settings = cnt_settings,
#         overwrite=True
#     )