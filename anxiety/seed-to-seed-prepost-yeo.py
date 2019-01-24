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


#subjects = ['102']

data_dir = '/home/data/nbc/physics-learning/data/pre-processed'
pre_dir = '/home/data/nbc/anxiety-physics/pre'
post_dir = '/home/data/nbc/anxiety-physics/post'
sink_dir = '/home/data/nbc/anxiety-physics/output'
#data_dir = '/Users/Katie/Dropbox/Data'
#work_dir = '/Users/Katie/Dropbox/Data/salience-anxiety-graph-theory'
directories = [pre_dir, post_dir]
sessions = ['pre', 'post']

yeo_7_ntwk_labels = ['Visual', 'Somatomotor', 'Dorsal Attention', 'Ventral Attention',
                     'Limbic', 'Frontoparietal', 'Default Mode']
yeo_7_regn_labels = ['Visual Cortex', 'Visual Precuneus R', 'Somatomotor', 'Dorsal Attention Posterior', 'Dorsal Attention MFG R',
                     'Dorsal Attention MFG L', 'Dorsal Attention Parahipp L', 'Ventral Attention IPL R', 'Ventral Attention AIns R',
                     'Ventral Attention Precent R', 'Ventral Attention IFG R', 'Ventral Attention MFG R', 'Ventral Attention CingSMA',
                     'Ventral Attention MFG L', 'Ventral Attention OFC L', 'Ventral Attention AIns L', 'Ventral Attention Precent L',
                     'Ventral Attention IPL L', 'Ventral Attention TPJ L', 'Limbic Amyg TempPole OFC', 'Frontoparietal ITG R', 'Frontoparietal Parietal R',
                     'Frontoparietal MFG R', 'Frontoparietal AIns R', 'Frontoparietal Precuneus', 'Frontoparietal A/MCC', 'Frontoparietal PCC',
                     'Frontoparietal SFG L', 'Frontoparietal MFG L', 'Frontoparietal ITG L', 'Frontoparietal Parietal L', 'Frontoparietal ITG R',
                     'Default Mode Temporal R', 'Default Mode Angular R', 'Default Mode IFG R', 'Default Mode SFG', 'Default Mode MedTemp R',
                     'Default Mode Precuneus', 'Default Mode Med Temp L', 'Default Mode ITG Angular L']


laird_2011_icns = '/home/data/nbc/anxiety-physics/17-networks-combo-ccn-5.14.nii.gz'
yeo_7_networks = '/home/kbott006/nilearn_data/yeo_2011/Yeo_JNeurophysiol11_MNI152/Yeo2011_7Networks_MNI152_FreeSurferConformed1mm_LiberalMask.nii.gz'
yeo_7_regions = '/home/kbott006/nilearn_data/yeo_2011/Yeo_JNeurophysiol11_MNI152/Yeo2011_7Network_Regions_MNI152_FreeSurferConformed1mm_LiberalMask.nii.gz'
network_masker = input_data.NiftiLabelsMasker(laird_2011_icns, standardize=True)
yeo_ntwk_masker = input_data.NiftiLabelsMasker(yeo_7_networks, standardize=True)
yeo_regn_masker = input_data.NiftiLabelsMasker(yeo_7_regions, standardize=True)

connectivity_metric = 'correlation'
conn_meas = ConnectivityMeasure(kind=connectivity_metric)

#determine the range of thresholds across which graph theoretic measures will be integrated
#threshold of 0.1 means the top 10% of connections will be retained
thresh_range = np.arange(0.1, 1, 0.1)

colnames = []
for session in sessions:
    for ntwk1 in yeo_7_ntwk_labels:
        for ntwk2 in yeo_7_ntwk_labels:
            colnames.append('{0}, {1}: {2}'.format(ntwk1,ntwk2,session))
df = pd.DataFrame(columns=colnames)

for s in subjects:
    ntwkconns = {}
    for i in np.arange(0, (len(sessions))):
        if not exists(join(sink_dir, sessions[i], s)):
            makedirs(join(sink_dir, sessions[i], s))
        fmri_file = join(directories[i], '{0}_filtered_func_data_mni.nii.gz'.format(s))
        confounds = join(sink_dir, sessions[i], s, '{0}_confounds.txt'.format(s))
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
        #network_time_series = network_masker.fit_transform(fmri_file, confounds)
        network_time_series = yeo_ntwk_masker.fit_transform(fmri_file, confounds)
        np.savetxt(join(sink_dir, sessions[i], s, '{0}_yeo7ntwk_ts.csv'.format(s)), network_time_series, delimiter=",")
        region_time_series = yeo_regn_masker.fit_transform (fmri_file, confounds)
        np.savetxt(join(sink_dir, sessions[i], s, '{0}_yeo7regn_ts.csv'.format(s)), region_time_series, delimiter=",")

        #network_correlation_matrix = connectivity.fit_transform([network_time_series])[0]
        network_correlation_matrix = conn_meas.fit_transform([network_time_series])[0]
        ntwk_corrmat = pd.DataFrame(data=network_correlation_matrix, index=yeo_7_ntwk_labels, columns=yeo_7_ntwk_labels)
        region_correlation_matrix = conn_meas.fit_transform([region_time_series])[0]
        regn_corrmat = pd.DataFrame(data=region_correlation_matrix, index=yeo_7_regn_labels, columns=yeo_7_regn_labels)
        ntwk_corrmat.to_csv(join(sink_dir, sessions[i], s, '{0}_yeo7_ntwk_corrmat.csv'.format(s)))
        regn_corrmat.to_csv(join(sink_dir, sessions[i], s, '{0}_yeo7_regn_corrmat.csv'.format(s)))

        #df.at[s, 'dmn-van {0}'.format(sessions[i])] = ntwk_corrmat['Default Mode']['Ventral Attention']
        #df.at[s, 'van-fpn {0}'.format(sessions[i])] = ntwk_corrmat['Ventral Attention']['Frontoparietal']
        #df.at[s, 'fpn-dmn {0}'.format(sessions[i])] = ntwk_corrmat['Frontoparietal']['Default Mode']

        for ntwk1 in yeo_7_ntwk_labels:
            for ntwk2 in yeo_7_ntwk_labels:
                ntwkconns['{0}, {1}: {2}'.format(ntwk1,ntwk2,sessions[i])] = ntwk_corrmat[ntwk1][ntwk2]
    ntwkconnser = pd.Series(ntwkconns, name=s)
    df = df.append(ntwkconnser)
df.to_csv(join(sink_dir, 'out_yeo7_conn.csv'))
