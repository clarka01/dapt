#%%
 
''' TODO: 
* seperate time periods and create histograms: 
            2002-2007, 2008-2012, 2012 - 2021 (build timing into parameters)
* stats for heirachal data (tableu?)

* measures (some integer, some %/ratios): downtime, 
            mkt rent, TIs, Free Mos, lease terms, Renewal Rate, Expenses

* Vars = {Geo: [State, CSAID, Submarket, Zip]}, Building Class: range(5), vacancy, building_age} 

* Stats: Mean, Median, Mode, Std. Dev., z-score, z-test;

* vizuals: histograms, rolling change, 

*** NOTES:
**  property service types - link to expenses?
**  
'''
 
#%%

pd.set_option('display.float_format', lambda x: '%.1f' % x)

# data processing
import numpy as np
import pandas as pd
from datetime import datetime, timedelta
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


# date vars

today_date = datetime.today() #with datetime
today = datetime.today().strftime('%Y-%m-%d') #y/m/d only
now = datetime.now()
monday_dt = now - timedelta(days = now.weekday()) 
monday = monday_dt.strftime('%Y-%m-%d')
# first_day_month = today_date.replace(day=1)
# first_day_current_month = first_day_month.date().strftime('%Y-%m-%d')
last_day_of_prev_month = date.today().replace(day=1) - timedelta(days=1)
start_day_of_prev_month = date.today().replace(day=1) - timedelta(days=last_day_of_prev_month.day)

month = today_date.strftime("%B").upper()



def query_costar(query):
    ''' query from Costar Database'''

    conn = pyodbc.connect('Driver={SQL Server};'
                        'Server=DESKTOP-V8FUEV1\SQL12345;'
                        'Database=Costar;'
                        'Trusted_Connection=yes;')
    cursor = conn.cursor()

    df = pd.read_sql_query(query, conn)

    return  df


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

    #extract year from lease 'fromdate'
    df['lease_start_year'] = pd.DatetimeIndex(df['fromdate']).year

    #calculate building age (years) from 'constructionyear'
    df['building_age'] = datetime.today().year - df['constructionyear']

    df.drop(columns = drop_cols, axis = 1, inplace=True)

    return df


df = merge_lease_geo()

df.shape

#%%

# PERCENT NULLS
def pct_null():
    '''% of null values for pca analysis'''
    
    null_pct = df.isna().sum()/df.shape[0]
    print(null_pct)

lst = pct_null()

# %%

# CORRELATOIN MATRIX/PLOT (JUST FOR FUN)

corr = df.corr()
sns.heatmap(corr)

#%%

# DESCRIPTIVE STATS
df.describe().T

#%%

