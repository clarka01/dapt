#%%
 
''' TODO: 
* column dtypes...historgrams...
** FEATURE ENGINEERING
    *remove submarket == null 

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
month = today_date.strftime("%B").upper()


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


def load_data():
    '''tries to read previous csv file to save pull time
        otherwise, pulls from aws server;
        ***REMOVES submarkets nulls'''

    try:   
        df = pd.read_csv('df_aws_merged.csv')

    except:
        def format_types():
            '''format types for analysis/visuals; object to int, float, date'''
            
            df = merge_lease_aws()

            #df.fillna('',inplace=True)

            to_float1 = ['leasedeal_id', 'property_id', 'property_type_id', 
                    'location_occupancy_id', 'service_type_id', 'sqft_min', 
                    'sqft_max', 'renewal', 'actual_vacancy', 'rba', 'lease_term_inmonths',
                    'free_months', 'cbsaid', 'buildingrating_id', 
                    'construction_year', 'zip', 'days_on_market'] 
                    #'building_age', #'lease_start_year'
            
            df[to_float1] = df[to_float1].applymap(float)
            # df[to_int] = df[to_int].applymap(int)
            '''see https://pandas.pydata.org/pandas-docs/stable/user_guide/gotchas.html#support-for-integer-na'''


            to_float2 = ['estimated_rent', 'rate_actual', 'tenantimprovementallowancepersqft']
            df[to_float2] = df[to_float2].applymap(float) 


            to_date = ['date_on_market', 'date_off_market', 'lease_sign_date',
                        'lease_expiration_date']
            df[to_date] = df[to_date].apply(pd.to_datetime, errors = 'coerce')

            # add col, lease_start year
            df['lease_start_year'] = pd.DatetimeIndex(df['from_date']).year
            # add col building_age
            df['building_age'] = datetime.today().year - df['construction_year']

            # remove submarket null values
            df.dropna(subset = ['submarket_name']) #1,067,141 to 900,083

            return df

        df = format_types()

    return df


def  csv_file_write():
    '''writes to df (remember to .gitignore this file since it's saving in the local repo) '''

    df = load_data()
    
    df.to_csv('df_aws_merged.csv', index = False)



'''DESCRIPTIVE STATS..................................'''

# PERCENT NULLS
def pct_null():
    '''% of null values for pca analysis/general needs'''
    
    null_pct = df_main.isna().sum()/df_main.shape[0] * 100
    print(null_pct)


# narrow columns to variables of interest

def desc_stats():

    '''reduces columns for describe() function; writes to csv (must .gitignore)'''

    num_cols = ['lease_term_inmonths','free_months', 
                'buildingrating_id', 'sqft_min', 'sqft_max', 
                'construction_year', 'days_on_market', 
                'lease_start_year', 'building_age', 'lease_expiration_date']

    df_desc = df_main[num_cols]

    # produce stats for outlier detection
    pcts = [.001,.01, .025, .25, .5, .75, .975, .99, .999]
    df_desc = df_main.describe(percentiles= pcts).T

    df_desc.to_csv('data_set_stats.csv', index = False)

    return df_desc

def desc_stat_col(col_name):
    '''quick function to see column stats '''

    pcts = [.001,.01, .025, .25, .5, .75, .975, .99, .999]

    df = df_main[col_name]

    print(df.describe(percentiles = pcts).T)


'''POPULATE DATA FRAME AND OVERRWRITE PREVIOUS CSV PREIOUS FILE'''
if __name__ == '__main__':
    df_main = load_data()
    csv_file_write()
    pct_null()
    desc_stats()
    

'''MODIFY VARIABLES'''

df_main['rent_diff'] = df_main.rate_actual / df_main.estimated_rent
df_main.rename(columns = {'tenantimprovementallowancepersqft':'ti'}, inplace = True)




#%%

'''HISTOGRAMS FOR KEY DATA COLUMNS & FEATURE ENGINEERING.............'''


#%%

def downtime_hist():
    '''downtime per leasedeal_id'''

    desc_stat_col('days_on_market')

    df = df_main

    pct = [.99]
    pct_99 = df.days_on_market.describe(percentiles = pct).loc['99%']
    min_down = df.days_on_market.min()


    df.days_on_market.hist(bins = 100, range = (min_down, pct_99))
    print()

downtime_hist()



#%%

def market_rent_hist():
    '''rent actual vs rent estimated (ratio) histogram'''

    desc_stat_col('estimated_rent')
    desc_stat_col('rate_actual')


    df = df_main

    df['rent_diff'] = df.rate_actual / df.estimated_rent

    df.rent_diff.hist(bins = 100, 
                     figsize = (12, 8), 
                     #log = True
                     range = (0,1))

market_rent_hist() #FUNCTION CALL



# %%

def tenant_improve_hist():
    '''tenant_allowance histogram'''

    print('PRE-OUTLIER REMOVAL')
    desc_stat_col('ti')

    df = df_main
    df['ti_pct'] = df.ti / (df.rate_actual/df.sqft_min)

    df = df[(df.ti_pct > 0)]


    print('POST-OUTLIER REMOVAL')
    print(df.ti_pct.describe())

    #use 99% for range max/min of 1
    print('POST OUTLIER REMOVAL')
    df.ti_pct.hist(bins = 100, 
                    # range = (0,1)
                    )

tenant_improve_hist()


#%%

def free_months_hist(): #would be worth correlating this with 

    '''free_months per leasedeal_id'''

    desc_stat_col('free_months')

    #remove '0's from free_months column
    df = df_main[(df_main.free_months > 0)]
    
    #use 99% for range max/min of 1
    pct = [.99]
    pct_99 = df.free_months.describe(percentiles = pct).loc['99%']
    min_free = df.free_months.min()

    # number of bins
    bin = (pct_99 - min_free).astype(np.int32)

    # % of leasedeal_ids w/ free months
    print(df.free_months.count() / df.shape[0])

    df.free_months.hist(bins = bin, range = (min_free, pct_99))

free_months_hist() #FUNCTION CALL



#%%

def lease_term_hist():
    ''' lease_term_in_months'''

    print('PRE-OUTLIER REMOVAL:')
    desc_stat_col('lease_term_inmonths')


# remove anything <= 0; 
    # create new data set, or eliminate these from entire set????
    df =  df_main.loc[~(df_main.lease_term_inmonths <= 0)] #900,083 to #893,993

    # histogram
    min_term = df.lease_term_inmonths.min()
    max_term = df.lease_term_inmonths.max()

    pct = [.99]
    pct_99 = df.lease_term_inmonths.describe(percentiles = pct).loc['99%']
    min_lease = df.lease_term_inmonths.min()

    print('POST-OUTLIER REMOVAL:')

    df.lease_term_inmonths.hist(bins = 100, 
                                figsize = (12, 8), 
                                color = 'green', 
                                range= (min_lease, pct_99), 
                                # log = True
                                ) 

lease_term_hist() #FUNCTION CALL



#%%

def service_type():
    '''service type value_counts'''
    df = df_main

    df1 = df.service_type_id.value_counts() / df.shape[0]

    # pct_service_id = "{:.2%}".format(df1)


    return df1

service_type()

#%%


###### RENEWAL RATES

def renewal_hist():

    '''renewal rate histogram'''

    df = df_main

    renewals = df.renewal[(df.renewal == 1)].count()

    pct_renewals = renewals / df.shape[0]

    pct_renewed = "{:.2%}".format(pct_renewals)

    return pct_renewed

renewal_hist()




#%%

'''OTHER VARIABLES AND CALCULATIONS.....................'''



def lease_start_hist():
    ''' lease_start_year histogram'''

    desc_stat_col('lease_start_year')

    df = df_main

    yr_min = df.lease_start_year.min()
    yr_max = df.lease_start_year.max()


    # for i, yr in enumerate(df.lease_start_year.unique()):
    #     print(i, yr)

    df.lease_start_year.hist(bins = 100, figsize = (12,8), range = (yr_min, yr_max))

    print(df.lease_start_year.value_counts().max())

lease_start_hist() #FUNCTION CALL




#%%

def building_age_hist():
    '''building age histogram'''

    desc_stat_col('building_age')


    df = df_main

    df.building_age.hist(bins = 300, range = [0,250])

    #5 buildings in construction as of 2021
    print(df.building_age.loc[(df.building_age < 0)].value_counts()) 

building_age_hist()






