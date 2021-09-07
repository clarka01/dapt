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
                        how = 'left', 
                        left_on = 'leasedealid',
                        right_on = 'LeaseDealID')

    null_count = df.isna().sum()
    null_pct = df.isna().sum()/df.shape[0]

    drop_cols = ['estimatedrent_x']

    df.drop(columns = drop_cols, axis = 1, inplace=True)

    return df

df = merge_lease_geo()
df.head()

# %%

def count_nulls(df):

    