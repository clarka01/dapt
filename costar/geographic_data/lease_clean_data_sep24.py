#%%

# data processing
import sys, os
import numpy as np
import pandas as pd
from datetime import datetime, timedelta
# from pandleau import *
import pyodbc 

try:
    import psycopg2
except:
    pass


# plotting
import matplotlib.pyplot as plt
import seaborn as sns


# set options: display

pd.set_option('display.float_format', lambda x: '%.1f' % x)


# repos (environment variables set)

LOCAL_REPOSITORY_LOCATION = os.environ.get('LOCAL_REPOSITORY_LOCATION')

os.chdir('../data_files')
print(os.getcwdb())


# date vars

today_date = datetime.today() #with datetime
today = datetime.today().strftime('%Y-%m-%d') #y/m/d only
now = datetime.now()
month = today_date.strftime("%B").upper()

#%%

def read_main():

    df = pd.read_csv(r'C:\Users\clark\Downloads' \
        r'\lease_clean_data_sep24.csv', index_col=0)

    df = df.drop([0])

    return df

df = read_main()
df.shape

#%%

def pct_null():
    '''% of null values for pca analysis/general needs'''
    
    null_pct = df_main.isna().sum()/df_main.shape[0] * 100
    print(null_pct)
    


def pct_null2():
    '''% of null values for pca analysis/general needs'''
    
    null_pct = df_main.isna().sum()
    print(null_pct)


# %%
