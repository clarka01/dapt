from azure.identity import DefaultAzureCredential, ClientSecretCredential
from azure.storage.blob import BlobServiceClient
from azure.storage.blob import BlobClient
from hbb_da_zen.hbb_lib import basic_utils as bu
from io import BytesIO

class Blob:
    """
    KeyVault represents a keyvault client session
    
    Attributes: vault_url : str
                        url to desired keyvault 
                        ex: https://hbbdakeyvaultdev.vault.azure.net/
            
    Examle Usage: client=KeyVault()
                  client.list_secrets()

    Returns: url class object
    """
    
    def __init__(self, storage_account_name='dastorageaccount01'):
        self.storage_account_name=storage_account_name


    def get_creds(self):
        '''
        gathers the configured credentials from basic_utils and instantiates a client secret credential
        '''
        content = bu.load_config()
        tenant_id = content["GRAPH"]['TENANT_ID']
        client_id = content["GRAPH"]['CLIENT_ID']
        client_secret = content["GRAPH"]['CLIENT_SECRET']
        
        credential=ClientSecretCredential(tenant_id=tenant_id, 
                                          client_id=client_id, 
                                          client_secret=client_secret)
        return credential

    
    def get_client(self):
        '''
        creates a client for keyvault using configured credentials
        '''
        credential = self.get_creds()
        blob_service = BlobServiceClient(account_url=f"https://{self.storage_account_name}.blob.core.windows.net",
                                                credential=credential
                                                )

        return blob_service

    
    def read_blob(self, container_name, blob_name):
        '''
        returns converted bytes object to use in pandas read_csv()
        '''

        blob_service = self.get_client()

        container = blob_service.get_container_client(container_name)

        blob = container.get_blob_client(blob_name)
        
        blob_stream=blob.download_blob().readall()
        
        data = BytesIO(blob_stream)

        return data

    
    def write_blob(self, bytes, container_name, blob_name, 
                   blob_type='BlockBlob', overwrite=True):
        '''
        write bytes object to blob by using pandas to_
        '''

        blob_type_map = {'BlockBlob':True,
                         'AppendBlob':False}

        blob_service = self.get_client()

        container = blob_service.get_container_client(container_name)
        
        blob = container.get_blob_client(blob_name)
        
        blob.upload_blob(data=bytes,
                         blob_type=blob_type,
                         overwrite=overwrite)

    
    def append_blob(self, bytes, container_name, blob_name):
        '''
        write bytes object to blob by using pandas to_
        '''
        blob_service = self.get_client()

        container = blob_service.get_container_client(container_name)
        
        blob = container.get_blob_client(blob_name)
        
        blob.append_block(data=bytes)

    
    def delete_blob(self, container_name, blob_name):
        '''
        write bytes object to blob by using pandas to_
        '''
        blob_service = self.get_client()

        container = blob_service.get_container_client(container_name)
        
        blob = container.get_blob_client(blob_name)
        
        blob.delete_blob()

    def list_blobs(self, container_name, folder_name):
        '''
        write bytes object to blob by using pandas to_
        '''
        blob_service = self.get_client()

        container = blob_service.get_container_client(container_name)
        
        blobs = [blob for blob in container.list_blobs() if blob.name.startswith(folder_name)] 
        
        return blobs

