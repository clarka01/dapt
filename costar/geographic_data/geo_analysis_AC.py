#%%
 
''' TODO: 
* column dtypes...historgrams...
*seperate time periods and create histograms: 
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
 
# data processing
import sys, os
import numpy as np
import pandas as pd
from datetime import datetime, timedelta
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
monday_dt = now - timedelta(days = now.weekday()) 
monday = monday_dt.strftime('%Y-%m-%d')
# first_day_month = today_date.replace(day=1)
# first_day_current_month = first_day_month.date().strftime('%Y-%m-%d')
# last_day_of_prev_month = date.today().replace(day=1) - timedelta(days=1)
# start_day_of_prev_month = date.today().replace(day=1) - timedelta(days=last_day_of_prev_month.day)

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


#%%

def merge_lease_sqlserv():
    '''pull sql server tables into DFs and merge, drop cols'''

    q1 = 'select * from dbo.merged_lease'
    df1 = query_costar(q1)

    q2 = 'select * from dbo.submarket_geo'
    df2 = query_costar(q2)

    df = pd.merge(df1, df2, 
                        how = 'left', 
                        left_on = 'leasedealid',
                        right_on = 'LeaseDealID')

    drop_cols = ['estimatedrent_x']

    #extract year from lease 'fromdate'
    df['lease_start_year'] = pd.DatetimeIndex(df['fromdate']).year

    #calculate building age (years) from 'constructionyear'
    df['building_age'] = datetime.today().year - df['constructionyear']

    df.drop(columns = drop_cols, axis = 1, inplace=True)

    return df

#%%

def merge_lease_aws():
#   '''connect to aws server'''

    import psycopg2

    connection = psycopg2.connect(
        host = 'lease-data.cnzawwknyviz.us-east-1.rds.amazonaws.com',
        port = 5432,
        user = 'costar',
        password = 'Costar12',
        database='costar'
        )
    cursor=connection.cursor()    

    df = pd.read_sql(
    '''
    SELECT *
    FROM lease_merged_sep
    ''', con=connection)
    
    return df

#%%

def load_data():
    
    try:
        df = merge_lease_aws()
    except: 
        df = merge_lease_sqlserv()

    return df

#%%


def format_types():
    '''format types for analysis/visuals; object to int, float, date'''
    
    df = load_data()

    df.fillna(0,inplace=True)

    to_int = ['leasedeal_id', 'property_id', 'property_type_id', 
            'location_occupancy_id', 'service_type_id', 'sqft_min', 
            'sqft_max', 'renewal', 'actual_vacancy', 'rba', 'lease_term_inmonths',
            'free_months', 'cbsaid', 'buildingrating_id', 
            'construction_year', 'zip', 'days_on_market'] 
            #'building_age', #'lease_start_year'
    
    df[to_int] = df[to_int].applymap(float)
    df[to_int] = df[to_int].applymap(int)


    to_float = ['estimated_rent', 'rate_actual', 'tenantimprovementallowancepersqft']
    df[to_float] = df[to_float].applymap(float) 


    to_date = ['date_on_market', 'date_off_market', 'lease_sign_date',
                'lease_expiration_date']
    df[to_date] = df[to_date].apply(pd.to_datetime, errors = 'coerce')

    # add col, lease_start year
    df['lease_start_year'] = pd.DatetimeIndex(df['from_date']).year
    # add col building_age
    df['building_age'] = datetime.today().year - df['construction_year']

    return df

df = format_types()

#%%

# PERCENT NULLS
def pct_null():
    '''% of null values for pca analysis/general needs'''
    
    null_pct = df.isna().sum()/df.shape[0]
    print(null_pct)

lst = pct_null()

# %%

'''CORRELATION MATRIX/PLOT (JUST FOR FUN)'''
corr = df.corr()
sns.heatmap(corr)

'''DESCRIPTIVE STATISTICS'''
df.describe().T

#%%
'''HISTOGRAMS.......................'''
# TODO: fill 0 with null in columns of interest


#%%

fig, axes = plt.subplots(nrows = 5, ncols = 2)

for i, col in enumerate(df.columns):
    print(i, col)

#%%

hist_size = (12,8)

df.lease_start_year.hist(bins = 100, figsize = (12,8), range = [1980,2024])

#%%

df.building_age.hist(bins = 300, figsize = hist_size, range = [0,250])

#%%

df.constructionyear.min()
#%%

df.constructionyear.hist(bins = 100, figsize = hist_size, range = [1900,2024])
#%%
max_estrent = df.estimatedrent_y.max() + 1

#%%
df.estimatedrent_y.hist(bins = 100, range = [0,max_estrent], figsize = hist_size, log = True)

#%%



