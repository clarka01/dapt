# how to adjust for lease start time? inflation plays into this.
    # do we group in years of 2, 3, 4, 5?
    # match this against economic data
# construction year might turn into 'age'
# buildingrating id is categorical--cluster analysis may be needed...
# use submarket vs CBSID?
# calculate STD for each region in terms of rent
    #which submarkets have the most variance? within AND outside of buildingratingid
# link population to this?

#%%

# data processing
import numpy as np
import pandas as pd
from datetime import date
import datetime as dt
import pyodbc 

# modeling
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import roc_curve, roc_auc_score
from sklearn.decomposition import PCA
from sklearn.pipeline import Pipeline

# plotting
import matplotlib.pyplot as plt
import seaborn as sns



import sys
import os

sys.path.append(os.path.abspath(r"C:\Users\clark\Documents\LOCAL_REPOSITORY_LOCATION\libraries"))

import sql_utils as su


# %%

def query_costar(query):
    ''' query from Costar Database'''

    conn = pyodbc.connect('Driver={SQL Server};'
                        'Server=DESKTOP-V8FUEV1\SQL12345;'
                        'Database=Costar;'
                        'Trusted_Connection=yes;')
    cursor = conn.cursor()

    df = pd.read_sql_query(query, conn)

    return  df

#%%

def merge_lease_geo():
    '''pull sql server tables into DFs and merge, drop cols'''

    q1 = 'select * from dbo.merged_lease'
    df1 = query_costar(q1)

    q2 = 'select * from dbo.submarket_geo'
    df2 = query_costar(q2)

    df = pd.merge(df1, df2, 
                        how = 'inner', 
                        left_on = 'leasedealid',
                        right_on = 'LeaseDealID')



    drop_cols = ['estimatedrent_x']

    df.drop(columns = drop_cols, axis = 1, inplace=True)

    return df

df = merge_lease_geo()
df.head()

#%%

def pct_null():
    null_pct = df.isna().sum()/df.shape[0]
    print(null_pct)

pct_null()

# %%

df.describe().T    

# %%
