from azure.identity import DefaultAzureCredential, ClientSecretCredential
from azure.keyvault.secrets import SecretClient
from ..hbb_lib import basic_utils as bu

class KeyVault:
    """
    KeyVault represents a keyvault client session
    
    Attributes: vault_url : str
                        url to desired keyvault 
                        ex: https://hbbdakeyvaultdev.vault.azure.net/
            
    Examle Usage: client=KeyVault()
                  client.list_secrets()

    Returns: url class object
    """
    
    def __init__(self, vault_url='https://hbbdakeyvaultdev.vault.azure.net/'):
        self.vault_url= vault_url


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
        secret_client=SecretClient(vault_url=self.vault_url, 
                        credential=self.get_creds())
        return secret_client
        

    def list_secrets(self):
        '''
        lists secrets from designated keyvault
        '''
        secret_client = self.get_client()
        secret_properties = secret_client.list_properties_of_secrets()
        for secret_property in secret_properties:
            print(secret_property.name)

    def get_secret(self, secret_name):
        '''
        Returns a keyvault secret value given a secret name

        Parameters: secret_name : str
                            secret name in the designated keyvault
                            ex: 'TestKey'

        Returns: secret.value

        '''
        secret_client = self.get_client()
        secret = secret_client.get_secret(secret_name)
        return secret.value

    
    def set_secret(self, secret_name, secret_key):
        secret_client = self.get_client()
        secret = secret_client.set_secret(secret_name, secret_key)
        print(f"{secret.name} : {secret.value}\n Uploaded Successfully")
        '''
        Set a new secret or update an exisiting secret value

        Parameters: secret_name : str
                            secret name in the designated keyvault
                            ex: 'TestKey'
        
                    secret_key : str
                            secret key in the designated keyvault
                            ex: '1ab8;3fg67!G'
                    
        Returns: prints status of action

        '''
    

    def delete_secret(self, secret_name, are_you_sure):
        if are_you_sure == 'yes': 
           secret_client = self.get_client()
           secret_client.begin_delete_secret(secret_name).result()
        print("Secret Successfully Deleted")
        '''
        Deletes a secret from the designated keyvault

        Parameters: secret_name : str
                            secret name in the designated keyvault
                            ex: 'TestKey'
        
                    are_you_sure : str
                            flag to make you think twice before you delete this key
                            ex: 'yes', 'no'
                    
        Returns: prints status of action

        '''
    
