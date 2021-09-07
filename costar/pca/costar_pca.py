#%%

import numpy as np
import pandas as pd
from datetime import date
import datetime as dt
import seaborn as sns
import matplotlib.pyplot as plt
import pyodbc 
pd.set_option("display.max_columns",999)
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

    