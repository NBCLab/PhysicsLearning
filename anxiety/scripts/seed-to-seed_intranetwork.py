from __future__ import division
import numpy as np
import datetime
import pandas as pd
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

anx_dir = '/home/data/nbc/physics-learning/anxiety-physics'
#anx_dir = '/Users/Katie/Dropbox/Projects/physics-anxiety'
labels = pd.read_csv(join(anx_dir, '17-networks-combo-ccn-5.14-regions-mni_labels.csv'), index_col=0, header=None, squeeze=True)
laird_2011_icn_regns = join(anx_dir, '17-networks-combo-ccn-5.14-regions-mni.nii.gz')

region_masker = input_data.NiftiLabelsMasker(laird_2011_icn_regns, standardize=True)

subjects = ["101", "102", "103", "104", "106", "107", "108", "110", "212",
            "214", "215", "216", "217", "218", "219", "320", "321", "323",
            "324", "325", "327", "328", "330", "331", "333", "334", "336",
            "337", "338", "339", "340", "341", "342", "343", "345", "346",
            "347", "348", "349", "350", "451", "455", "458", "459",
            "460", "462", "463", "464", "467", "468", "469", "470", "502",
            "503", "571", "572", "573", "574", "577", "578", "581", "582",
            "584", "586", "588", "589", "591", "592", "593", "594", "595",
            "596", "597", "598", "604", "605", "606", "607", "608", "609",
            "610", "612", "613", "614", "615", "617", "618", "619", "620",
            "621", "622", "623", "624", "625", "626", "627", "629", "630",
            "631", "633", "634"]


#subjects = ['102','103']

data_dir = '/home/data/nbc/physics-learning/data/pre-processed'
pre_dir = '/home/data/nbc/physics-learning/anxiety-physics/pre'
post_dir = '/home/data/nbc/physics-learning/anxiety-physics/post'
sink_dir = '/home/data/nbc/physics-learning/anxiety-physics/output'
#data_dir = '/Users/Katie/Dropbox/Data'
#pre_dir = '/Users/Katie/Dropbox/Projects/physics-anxiety/test/pre'
#post_dir = '/Users/Katie/Dropbox/Projects/physics-anxiety/test/post'
#sink_dir = '/Users/Katie/Dropbox/Projects/physics-anxiety/test/output'
lab_notebook_dir = '/home/kbott006/lab_notebook/'

directories = [pre_dir, post_dir]
sessions = ['pre', 'post']

lab_notebook = pd.DataFrame(index=subjects, columns=['start', 'end', 'errors'])
intrantwk_conn = pd.DataFrame(index=subjects, columns=set(labels))

for i in np.arange(0, (len(sessions))):
    print(sessions[i])
    for s in subjects:
        lab_notebook.at[s,'start'] = str(datetime.datetime.now())
        try:
            if not exists(join(sink_dir, sessions[i], s)):
                makedirs(join(sink_dir, sessions[i], s))
            fmri_file = join(directories[i], '{0}_filtered_func_data_mni.nii.gz'.format(s))
            print(fmri_file)
            confounds = join(sink_dir, sessions[i], s, '{0}_confounds.txt'.format(s))
            #print confounds
            #create correlation matrix from PRE resting state files
            region_time_series = region_masker.fit_transform(fmri_file, confounds)
            print(region_time_series.shape)
            np.savetxt(join(sink_dir, sessions[i], s, '{0}_laird2011_ts_regions.csv'.format(s)), region_time_series, delimiter=",")
            #region_time_series = region_masker.fit_transform (fmri_file, confounds)
            #connectivity = ConnectivityMeasure(kind='correlation')

            #network_correlation_matrix = connectivity.fit_transform([network_time_series])[0]
            region_correlation_matrix = np.corrcoef(region_time_series.T)
            corrmat = pd.DataFrame(region_correlation_matrix, index=labels.index, columns=labels.index)

            corrmat.to_csv(join(sink_dir, sessions[i], s, '{0}_corrmat_Laird2011.csv'.format(s)), sep=",")
            intranetwork = {}
            for network in set(labels.values):
                #print(network)
                indices = labels.iloc[labels.values == network].index.values
                #print(indices)
                net_corrs = []
                for k in indices:
                    for j in indices:
                        if k != j:
                            net_corrs.append(region_correlation_matrix[k,j])
                        else:
                            pass
                intranetwork[network] = np.mean(net_corrs)
                intrantwk_conn.at[s,network] = np.mean(net_corrs)
            print('trying to write out intranetwork_connectivity',s,sessions[i],datetime.datetime.now())
            #wtf = pd.Series(intranetwork, name='intranetwork connectivity')
            #wtf.to_csv(sink_dir, sessions[i], s, '{0}_intranetwork_connectivity_Laird2011.csv'.format(s))
            #intrantwk_conn.to_csv(join(sink_dir, '{0}_intranetwork_connectivity.csv'.format(sessions[i])), sep=",")
            lab_notebook.at[s,'end'] = str(datetime.datetime.now())
        except Exception as e:
            print(s, e, str(datetime.datetime.now()))
            lab_notebook.at[s,'errors'] = 'error with {0}, {1}: {2}, {3}'.format(s, sessions[i],str(datetime.datetime.now()),e)
        print('ending subject {0}, session {1}. trying to save intranetwork'.format(s,i))
        intrantwk_conn.to_csv(join(sink_dir, '{0}_intranetwork_connectivity.csv'.format(sessions[i])), sep=",")
lab_notebook.to_csv(join(lab_notebook_dir, 'seed-to-seed-intranetwork_{0}.csv'.format(str(datetime.datetime.now()))))
