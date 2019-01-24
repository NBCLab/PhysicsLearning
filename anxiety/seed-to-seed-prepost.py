from __future__ import division
import numpy as np
from glob import glob
from os.path import join, basename, exists
from os import makedirs
import matplotlib.pyplot as plt
from nilearn import input_data
from nilearn import datasets
import pandas as pd
from nilearn import plotting
from nilearn.image import concat_imgs
from nilearn.input_data import NiftiLabelsMasker
from nilearn.connectome import ConnectivityMeasure
import bct

subjects = ["101", "102", "103", "104", "106", "107", "108", "110", "212",
            "214", "215", "216", "217", "218", "219", "320", "321", "323",
            "324", "325", "327", "328", "330", "331", "333", "334", "336",
            "337", "338", "339", "340", "341", "342", "343", "345", "346",
            "347", "348", "349", "350", "451", "453", "455", "458", "459",
            "460", "462", "463", "464", "467", "468", "469", "470", "502",
            "503", "571", "572", "573", "574", "577", "578", "581", "582",
            "584", "586", "588", "589", "591", "592", "593", "594", "595",
            "596", "597", "598", "604", "605", "606", "607", "608", "609",
            "610", "612", "613", "614", "615", "617", "618", "619", "620",
            "621", "622", "623", "624", "625", "626", "627", "629", "630",
            "631", "633", "634"]


subjects = ['102']

data_dir = '/home/data/nbc/physics-learning/data/pre-processed'
pre_dir = '/home/data/nbc/anxiety-physics/pre'
post_dir = '/home/data/nbc/anxiety-physics/post'
sink_dir = '/home/data/nbc/anxiety-physics/output'
#data_dir = '/Users/Katie/Dropbox/Data'
#work_dir = '/Users/Katie/Dropbox/Data/salience-anxiety-graph-theory'
directories = [pre_dir, post_dir]
sessions = ['pre', 'post']

laird_2011_icns = '/home/data/nbc/anxiety-physics/17-networks-combo-ccn-5.14.nii.gz'
network_masker = input_data.NiftiLabelsMasker(laird_2011_icns, standardize=True)

connectivity_metric = 'correlation'

#determine the range of thresholds across which graph theoretic measures will be integrated
#threshold of 0.1 means the top 10% of connections will be retained
thresh_range = np.arange(0.1, 1, 0.1)

for i in np.arange(0, (len(sessions))):
    print sessions[i]
    for s in subjects:
        if not exists(join(sink_dir, sessions[i], s)):
            makedirs(join(sink_dir, sessions[i], s))
        fmri_file = join(directories[i], '{0}_filtered_func_data_mni.nii.gz'.format(s))
        print fmri_file
        confounds = join(sink_dir, sessions[i], s, '{0}_confounds.txt'.format(s))
        print confounds
        #post_fmri_file = join(post_dir, '{0}_filtered_func_data_mni.nii.gz'.format(s))

        #read in motion parameters from mcflirt output file
        #motion = np.genfromtxt(join(data_dir, s, 'session-{0}'.format(i), 'resting-state', 'resting-state-0', 'endor1.feat', 'mc', 'prefiltered_func_data_mcf.par'))
        #outliers_censored = join(directories[i], '{0}_confounds.txt'.format(s))

        #if exists(outliers_censored):
            #print "outliers file exists!"
            #outliers = np.genfromtxt(pre_outliers_censored)
            #confounds = outliers_censored

        #else:
            #print "No outliers file found for {0} {1}".format(sessions[i], s)
            #np.savetxt((join(sink_dir, sessions[i], s, '{0}_confounds.txt'.format(s))), motion)
            #confounds = join(data_dir, s, 'session-{0}'.format(i), 'resting-state', 'resting-state-0', 'endor1.feat', 'mc', 'prefiltered_func_data_mcf.par')

        #create correlation matrix from PRE resting state files
        network_time_series = network_masker.fit_transform(fmri_file, confounds)
        print network_time_series.shape
        np.savetxt(join(sink_dir, sessions[i], s, '{0}_laird2011_ts.csv'.format(s)), network_time_series, delimiter=",")
        #region_time_series = region_masker.fit_transform (fmri_file, confounds)
        #connectivity = ConnectivityMeasure(kind='correlation')

        #network_correlation_matrix = connectivity.fit_transform([network_time_series])[0]
        network_correlation_matrix = np.corrcoef(network_time_series)
        print network_correlation_matrix
        #network_correlation_matrix = np.corrcoef(network_time_series)
        #region_correlation_matrix = correlation_measure.fit_transform([region_time_series])[0]
        #np.savetxt(join(sink_dir, sessions[i], s, '{0}_region_corrmat_Yeo7.csv'.format(s)), region_correlation_matrix, delimiter=",")
        np.savetxt(join(sink_dir, sessions[i], s, '{0}_network_corrmat_Laird2011.csv'.format(s)), network_correlation_matrix, delimiter=",")

        network = {}
        network_wise = {}

        #talking with Kim:
        #start threhsolding (least conservative) at the lowest threshold where you lose your negative connection weights
        #steps of 5 or 10 percent
        #citation for integrating over the range is likely in the Fundamentals of Brain Network Analysis book
        #(http://www.danisbassett.com/uploads/1/1/8/5/11852336/network_analysis_i__ii.pdf)
        #typically done: make sure your metric's value is stable across your range of thresholds
        #the more metrics you use, the more you have to correct for multiple comparisons
        #make sure this is hypothesis-driven and not fishing

        for p in thresh_range:
            ge = []
            cc = []
            ntwk_corrmat_thresh = bct.threshold_proportional(network_correlation_matrix, p, copy=True)
            #np.savetxt(join(sink_dir, sessions[i], s, '{0}_corrmat_Laird2011_thresh_{1}.csv'.format(s, p)), ntwk_corrmat_thresh, delimiter=',')
            #measures of interest here
            #global efficiency
            le = bct.efficiency_wei(ntwk_corrmat_thresh)
            ge.append(le)

            #clustering coefficient
            c = bct.clustering_coef_wu(ntwk_corrmat_thresh)
            cc.append(c)

            network[p] = ge
            network_wise[p] = cc


        ntwk_df = pd.Series(network).T
        #ntwk_df.columns = ['total positive', 'total negative', 'efficiency', 'path length', 'modularity']

        ntwk_wise_df = pd.Series(network_wise).T
        #ntwk_wise_df.columns = ['betweenness', 'degree', 'positive weights', 'negative weights',
        #                                                   'community index', 'clustering coefficient']
        ntwk_df.to_csv(join(sink_dir, sessions[i], s, '{0}_network_metrics.csv'.format(s)), sep=',')
        ntwk_wise_df.to_csv(join(sink_dir, sessions[i], s, '{0}_network_wise_metrics.csv'.format(s)), sep=',')
