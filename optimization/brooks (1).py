##### 
# Helper file for Pyomo and for fitting distributions
# Contains
# 1. my_chisquare - a function to conduct a chi-square goodness of fit test
# 2. test_distribution - generates a histogram for data to generate bins, then applies a chi-square gof test for a specified distribution.  Choices are: normal, exponential, uniform, triangular, gamma, beta, lognormal
# 3. A Model class that inherits from Pyomo's ConcreteModel that includes a redefinition of the delete() function for deleting all related components.  For example, for a constraint list, the function deletes the constraint list and the associated index component.
######
# Author: Paul Brooks
# Last updated: January 16, 2021
# Changelog: 1/16/21: added lognormal, beta, gamma distributions
# 4/21/21: fixed message for gamma printing alpha instead of loc
######

import pyomo.environ 
def my_chisquare(my_data, expected_cdf, observed_values, my_dof, distribution):
    import numpy as np
    from scipy import stats
    # use the expected cdf to get the expected values
    expected_values = len(my_data)*np.diff(expected_cdf)
    # conduct the chi-square test
    c, p = stats.chisquare(observed_values, expected_values, ddof=my_dof)

    print("The test statistic for a %s distribution is %f and the p-value is %f." % (distribution, c, p))

def test_distribution(my_data, distribution='normal'):
    import numpy as np
    from scipy import stats

    # get histogram bins for observed values
    histo, bin_edges = np.histogram(my_data, bins='auto')
    observed_values = histo
    # find best parameters for the distribution and generate the expected cdf
    # my_dof is the number of parameters estimated
    if distribution == 'exponential':
        (my_floc, my_scale) = stats.expon.fit(my_data, floc=0)
        print("For an exponential distribution, the scale parameter estimate is %f." % my_scale)
        expected_cdf = stats.expon.cdf(bin_edges, 
                                       scale=my_scale)
        my_dof = 1
        my_chisquare(my_data, expected_cdf, observed_values, my_dof, distribution)
        return my_scale
    elif distribution == 'normal':
        (my_loc, my_scale) = stats.norm.fit(my_data)
        print("For a normal distribution, the mean estimate is %f and the standard deviation estimate is %f." % (my_loc, my_scale))
        expected_cdf = stats.norm.cdf(bin_edges, 
                                      loc=my_loc, 
                                      scale=my_scale)
        my_dof = 2
        my_chisquare(my_data, expected_cdf, observed_values, my_dof, distribution)
        return (my_loc, my_scale)
    elif distribution == 'triangular':
        (my_c, my_loc, my_scale) = stats.triang.fit(my_data)
        print("For a triangular distribution, the min estimate is %f, the mode estimate is %f, and the max estimate is %f." % (my_loc, my_loc+my_c*my_scale, my_loc+my_scale))
        expected_cdf = stats.triang.cdf(bin_edges, 
                                        c=my_c, 
                                        loc=my_loc, 
                                        scale=my_scale)
        my_dof = 3
        my_chisquare(my_data, expected_cdf, observed_values, my_dof, distribution)
        return (my_loc, my_loc+my_c*my_scale, my_loc+my_scale)
    elif distribution == 'uniform':
        (my_loc, my_scale) = stats.uniform.fit(my_data)
        print("For a uniform distribution, the min estimate is %f and the max estimate is %f." % (my_loc, my_loc+my_scale))
        expected_cdf = stats.uniform.cdf(bin_edges,
                                         loc=my_loc,
                                         scale=my_scale)
        my_dof = 2
        my_chisquare(my_data, expected_cdf, observed_values, my_dof, distribution)
        return (my_loc, my_loc+my_scale)
    elif distribution == 'beta':
        (my_alpha, my_beta, my_loc, my_scale) = stats.beta.fit(my_data, floc=0.0, fscale=1.0) # fixing min and max to match numpy beta; could use scipy.rvs() instead.  See https://stackoverflow.com/questions/16016959/scipy-stats-seed, answer from 2020
        #my_scale = max(my_data) - min(my_data)
        print("For a beta distribution, the alpha estimate is %f, the beta estimate is %f, the min estimate is %f and the max estimate is %f." % (my_alpha, my_beta, my_loc, my_loc+my_scale))
        expected_cdf = stats.beta.cdf(bin_edges,
                a=my_alpha,
                b=my_beta, 
                loc=0.0,
                scale=1.0)
        my_dof = 4
        my_chisquare(my_data, expected_cdf, observed_values, my_dof, distribution)
        return (my_alpha, my_beta, my_loc, my_loc+my_scale)
    elif distribution == 'gamma':
        (my_alpha, my_loc, my_scale) = stats.gamma.fit(my_data, floc=0.0)
        print("For a gamma distribution, the alpha estimate is %f and the beta estimate is %f." % (my_alpha, 1.0/my_scale))
        expected_cdf = stats.gamma.cdf(bin_edges,
                a=my_alpha,
                loc=0.0,
                scale=my_scale)
        my_dof = 2
        my_chisquare(my_data, expected_cdf, observed_values, my_dof, distribution)
        return (my_alpha, 1.0/my_scale)
    elif distribution == 'lognormal':
        (my_s, my_loc, my_scale) = stats.lognorm.fit(my_data, floc=0.0)
        print("For a lognormal distribution, the log mean estimate is %f and the log stdev estimate is %f." % (np.log(my_scale), my_s))
        expected_cdf = stats.lognorm.cdf(bin_edges,
                s=my_s,
                loc=0.0,
                scale=my_scale)
        my_dof = 2
        my_chisquare(my_data, expected_cdf, observed_values, my_dof, distribution)
        return (np.log(my_scale), my_s)
    else:
        print("%s distribution is not implemented.  The implemented distributions are normal, exponential, uniform, triangular, lognormal, gamma, and beta." % distribution)
        return

class Model(pyomo.environ.ConcreteModel):
    def __init__(self):
        pyomo.environ.ConcreteModel.__init__(self)
    def delete(self, comp):
        attributes = list(self.__dict__.keys())
        for attribute in attributes:
            index_name = comp.name + "_index"
            if comp.name == attribute:
                self.del_component(self.__dict__[attribute])
            elif index_name in attribute:
                self.del_component(self.__dict__[attribute])


