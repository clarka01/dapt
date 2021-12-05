#%%

#LIBRARIES

import pandas as pd
import datetime
import psycopg2
import numpy as np
import os
import seaborn as sns
pd.set_option("display.max_columns",999)
import seaborn as sns
import random
import time
import math

from sklearn.model_selection import train_test_split
from fitter import Fitter #, get_common_distributions, get_distributions
#from scipy import stats
#import scipy.integrate as integrate
#from scipy.integrate import quad

import warnings
warnings.filterwarnings('ignore')

pd.options.display.float_format = '{:.2f}'.format
get_ipython().run_line_magic('matplotlib', 'inline')
import matplotlib.pyplot as plt
plt.style.use('seaborn-white')

# PATHS

LOCAL = os.environ['LOCAL_REPOSITORY_LOCATION']
folder_dist = 'DAPT\costar\distributions'
path_dist = os.path.join(LOCAL, folder_dist)
fn = 'lease_clean_oct29.csv'

# VARIABLES

# FITTER selected distributions

# common distributions from Fitter
# dists = list(get_common_distributions())
# dists_all = list(get_distributions())

expon = 'expon'
gamma = 'gamma'
genpareto = 'genpareto'
gilbrat = 'gilbrat'
halfgennorm = 'halfgennorm'
halflogistic = 'halflogistic'
lognorm = 'lognorm'
lomax = 'lomax'
pareto = 'pareto'
reciprocal = 'reciprocal'
truncexpon = 'truncexpon'
wald = 'wald'



DISTS = [expon, gamma, genpareto, gilbrat, halfgennorm, halflogistic, lognorm, lomax,
        pareto, reciprocal, truncexpon, wald]



# SCIPY AUTO-FIT


from scipy.stats import (
    # norm, beta, expon, gamma, genextreme, logistic, lognorm, triang, uniform, fatiguelife,            
    # gengamma, gennorm, dweibull, dgamma, gumbel_r, powernorm, rayleigh, weibull_max, weibull_min, 
    # laplace, alpha, genexpon, bradford, betaprime, burr, fisk, genpareto, hypsecant, 
    # halfnorm, halflogistic, invgauss, invgamma, levy, loglaplace, loggamma, maxwell, 
    # mielke, ncx2, ncf, nct, nakagami, pareto, lomax, powerlognorm, powerlaw, rice, 
    # semicircular, trapezoid, rice, invweibull, foldnorm, foldcauchy, cosine, exponpow, 
    # exponweib, wald, wrapcauchy, truncexpon, truncnorm, t, rdist
    truncexpon, genpareto
    )

distributions = [
    # norm, beta, expon, gamma, genextreme, logistic, lognorm, triang, uniform, fatiguelife,            
    # gengamma, gennorm, dweibull, dgamma, gumbel_r, powernorm, rayleigh, weibull_max, weibull_min, 
    # laplace, alpha, genexpon, bradford, betaprime, burr, fisk, genpareto, hypsecant, 
    # halfnorm, halflogistic, invgauss, invgamma, levy, loglaplace, loggamma, maxwell, 
    # mielke, ncx2, ncf, nct, nakagami, pareto, lomax, powerlognorm, powerlaw, rice, 
    # semicircular, trapezoid, rice, invweibull, foldnorm, foldcauchy, cosine, exponpow, 
    # exponweib, wald, wrapcauchy, truncexpon, truncnorm, t, rdist
        truncexpon, genpareto

    ]

# Kolmogorov-Smirnov KS test for goodness of fit: samples
# ksN = 100
# significance level for hypothesis test
# ALPHA = 0.05       



# DATA FILTER VARIABLES

# minimum lease CNT in best_fit analysis (min = 20: df = 40, dfA = 20, dfB = 20)
MIN_LEASE_COUNT = 20

# include vacancy_months dataset
INCLUDE_ZERO  = False

# start and end dates for reading data frame
START_DATE = 2008
END_DATE = 2020

# variable strings
A = 'A'
B = 'B'
aic = 'aic'
bic = 'bic'
sumsquare_error = 'sumsquare_error'

#TODO: see what other fits to add to DISTS...

#%%

def read_data(start_date, end_date):
    # reads in Oct 29 rds lease data
    
    conn = psycopg2.connect(
        host = 'lease-data.cnzawwknyviz.us-east-1.rds.amazonaws.com',
        port = 5432,
        user = 'costar',
        password = 'Costar12',
        database='costar'
        )
    cursor = conn.cursor() 

    try:
        df = pd.read_csv(os.path.join(path_dist, 'downtime_lease_nov22.csv'))
        # old source
        # df = pd.read_csv(os.path.join(path_dist, 'downtime_rent.csv')) 

        
    except:
        q = '''
            SELECT
                *
            FROM downtime_lease_nov8
            '''
        df = pd.read_sql(q, 
                         con = conn)
        # print('Data Source: RDS')
        #logger('Data Source: RDS')

    #strip whitespace
    df.cbsa_state_new = df.cbsa_state_new.str.strip()

    #replace '-' w/ '_'
    df.cbsa_state_new = df.cbsa_state_new.replace('-', '_')


    # include or do not include 0 vacant months in analysis
    if INCLUDE_ZERO:
        df = df

    else:
        df = df[df.vacant_months > 0]

    # cbsa to integer
    df.cbsaid = df.cbsaid.astype(np.int)

    # filter by dates (2008 - 2020)
    df = df[(df['year_off_market'] >= start_date) & (df['year_off_market'] <= end_date) ]

    return df

df = read_data(START_DATE, END_DATE)


#%%


def top_cbsa(start, end):
    # Returns list of top 'n' cbsa by count of leasedeal_id's

    # df = read_data()
    #TODO: 'uncomment function above after putting code into prod'

    # determine top CBSAs by leasedeal count
    dfc = df.groupby('cbsaid')['leasedeal_id'].count().reset_index()
    
    # sort by top n CBSA, to list
    dfcl = dfc.sort_values(by = 'leasedeal_id', ascending = False)

    # filter by minimum lease count after split (variable)
    dfcl = dfcl[dfcl.leasedeal_id / 2 > MIN_LEASE_COUNT]

    #specify start, end rows
    dfcl = dfcl.iloc[start:end,0:1]

    # to list
    top = dfcl.cbsaid.to_list()

    print(f'count of CBSAs: {len(top)}')
    print(f'minimum lease count A/B (after split): {MIN_LEASE_COUNT}')
    
    return top

#%%

def dist_national(d):
    # fits entire data set (all CBSAIDs)
    
    # vacant_months as list for frequency distribution
    dt = df.vacant_months.to_list()
    
    f = Fitter(dt,
               distributions = d)
    # graph
    f.fit()

    # summary of stats
    f.summary()

    s = f.get_best(method = 'aic')  
    # t = f.get_best(method = 'bic')  
    # u = f.get_best(method = 'sumsquare_error')  
    
    return s #, t, u

dist_national(DISTS) #verified that parameters don't change according to bin


#%%
def dist_cbsa(cbsa):
    # outputs best-fit distribution of CBSA before splitting data 
    # (ensures same dist for both)

    # df = read_data()

    #filter df by specified cbsa    
    df2 = df[df.cbsaid == cbsa ]

    # downtime frequency as list / into fitter
    dt = df2.vacant_months.to_list()
    f = Fitter(dt,
               distributions = DISTS)

    #%% fitter.py bins = 28

    f.fit()

    # display graph w/ fit lines
    f.summary()

    # display best fit & parameters (e.g. exponpow b:, loc:, scale:)
    s = f.get_best(method = 'aic')
    # t = f.get_best(method = 'bic')
    # u = f.get_best(method = 'sumsquare_error')

    # retains key (best fit distribution) from dictinary object
    k = list(s)[0]
    # h = list(t)[0]
    # i = list(u)[0]

    return cbsa, k, # h, i

#bins have an affect on the line fit within the historgram plot
a = dist_cbsa(top_cbsa(0,-1)[0])

#%%

def dist_cbsa_list(start, end):
    # function lists out cbsaid and distribution best fit

    # puts id and best fit into list based on top 'n' cbsa's
    cbsa_fit = [dist_cbsa(i) for i in top_cbsa(start, end)]

    #keeps cbsaid & best_fit columns
    df = pd.DataFrame(cbsa_fit, columns = ['cbsaid', 'best_fit'])

    return df


df_dist = dist_cbsa_list(0,-1)

# df_dist.to_csv('distributions_best_fit.csv', index = False)


#%%


def dist_cbsa_split_A(cbsa):
    # gets dist by cbsaid

    #TODO: uncomment when code into production
    # dist_cbsa_list(0, -1)
    
    #TODO: uncomment when code into production
    # df = read_data()
        
    # filter main df by cbsaid parameter
    df2 = df[df.cbsaid == cbsa]

    # split to main cbsa-specific df to A / B
    dfA, dfB = train_test_split(df2, test_size = 0.5, random_state = 17325)

    # selects best_fit from df_dist (cbsa: best_fit)
    d = df_dist.loc[df_dist.cbsaid == cbsa].best_fit.to_list()

    # Fit A, summary A

    # A Data Frame =====================
 
    dtA = dfA.vacant_months.to_list()
    fA = Fitter(dtA,
               distributions = d)

    fA.fit()
    # f.summary()
    sA = fA.get_best(method = 'aic')


    # dict to dataframe / format
    dfmA = pd.DataFrame.from_dict(sA, orient = 'index').reset_index()
    dfmA['cbsa'] = cbsa
    dfmA['AB'] = 'A'

    return dfmA

dist_cbsa_split_A(11244)

#%%

def dist_cbsa_split_B(cbsa):
    # gets dist by cbsaid

    #TODO: uncomment when code into production
    # dist_cbsa_list(0, -1)
    
    #TODO: uncomment when code into production
    # df = read_data()
        
    # filter main df by cbsaid parameter
    df2 = df[df.cbsaid == cbsa]

    # split to main cbsa-specific df to A / B
    dfA, dfB = train_test_split(df2, test_size = 0.5, random_state = 17325)

    # selects best_fit from df_dist (cbsa: best_fit)
    d = df_dist.loc[df_dist.cbsaid == cbsa].best_fit.to_list()

    # Fit B, summary B
    # B Data Frame =====================

    dtB = dfB.vacant_months.to_list()
    fB = Fitter(dtB,
               distributions = d)

    fB.fit()
    # f.summary()
    sB = fB.get_best(method = 'aic')

    # dict to dataframe / format
    dfmB = pd.DataFrame.from_dict(sB, orient = 'index').reset_index()
    dfmB['cbsa'] = cbsa
    dfmB['AB'] = 'B'
        
    return dfmB

# a, b = dist_cbsa_split(11244)
# c, d = dist_cbsa_split(15940)

# df10 = pd.concat([a,b,c,d])

# df10.head(10)

#%%


def concat_cbsa_fits_params():
    # taking params for all cbsas / concat

    # combine all fits / parameters for A split
    dfsA = []
    for cbsa in top_cbsa(0,-1):
        df99 = dist_cbsa_split_A(cbsa)
        dfsA.append(df99)

    dfmA = pd.concat(dfsA)



    # combine all fits / parameters for B split

    dfsB = []
    for cbsa in top_cbsa(0,-1):
        df98 = dist_cbsa_split_B(cbsa)
        dfsB.append(df98)

    dfmB = pd.concat(dfsB)

    # combine fits A & fits B
    dfm = pd.concat([dfmA, dfmB])

    # format / drop columns
    dfm.reset_index(inplace=True)
    dfm.drop(columns = 'level_0', inplace = True)

    # ensure correct renaming occurs below:
    print(dfm.columns)

    # A & B sets to columns / flatten df / rename / rearrange
    df10 = pd.pivot_table(dfm,
                         index = ['cbsa', 'index'],
                         columns = ['AB'], 
                         values= ['b', 'c', 'loc', 'scale']
                        )
    
    df11 = pd.DataFrame(df10.to_records())

    df11.rename(columns = { df11.columns[1]: 'best_fit',
                            df11.columns[2]: 'b1', 
                            df11.columns[3]: 'b2', 
                            df11.columns[4]: 'c1',
                            df11.columns[5]: 'c2',
                            df11.columns[6]: 'loc1',
                            df11.columns[7]: 'loc2',
                            df11.columns[8]: 'scale1',
                            df11.columns[9]: 'scale2'
                          }, 
                          inplace = True
                )
    
    # rearrange columns
    cols = ['cbsa', 'best_fit', 
            'b1', 'c1', 'loc1', 'scale1', 
            'b2', 'c2', 'loc2', 'scale2']

    dff = df11[cols]



    return dff

#final output for best distribution fit for fitter library.
dfm = concat_cbsa_fits_params()

dfm.to_csv(r'best_fit_by_cbsa.csv', index = False)

