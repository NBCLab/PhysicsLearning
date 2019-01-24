import pandas as pd
import numpy as np
from os.path import join

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


subjects = ['101', '102']

data_dir = '/home/data/nbc/physics-learning/data/pre-processed'
sink_dir = '/home/data/nbc/anxiety-physics/output'
#data_dir = '/Users/Katie/Dropbox/Data'
#work_dir = '/Users/Katie/Dropbox/Data/salience-anxiety-graph-theory'
sessions = ['pre', 'post']

yeo_7_regn_labels = ['Visual Cortex', 'Visual Precuneus R', 'Somatomotor', 'Dorsal Attention Posterior', 'Dorsal Attention MFG R',
                     'Dorsal Attention MFG L', 'Dorsal Attention Parahipp L', 'Ventral Attention IPL R', 'Ventral Attention AIns R',
                     'Ventral Attention Precent R', 'Ventral Attention IFG R', 'Ventral Attention MFG R', 'Ventral Attention CingSMA',
                     'Ventral Attention MFG L', 'Ventral Attention OFC L', 'Ventral Attention AIns L', 'Ventral Attention Precent L',
                     'Ventral Attention IPL L', 'Ventral Attention TPJ L', 'Limbic Amyg TempPole OFC', 'Frontoparietal ITG R', 'Frontoparietal Parietal R',
                     'Frontoparietal MFG R', 'Frontoparietal AIns R', 'Frontoparietal Precuneus', 'Frontoparietal A/MCC', 'Frontoparietal PCC',
                     'Frontoparietal SFG L', 'Frontoparietal MFG L', 'Frontoparietal ITG L', 'Frontoparietal Parietal L', 'Frontoparietal ITG R',
                     'Default Mode Temporal R', 'Default Mode Angular R', 'Default Mode IFG R', 'Default Mode SFG', 'Default Mode MedTemp R',
                     'Default Mode Precuneus', 'Default Mode Med Temp L', 'Default Mode ITG Angular L']

colnames = []
for session in sessions:
    for regn1 in yeo_7_regn_labels:
        for regn2 in yeo_7_regn_labels:
            colnames.append('{0}, {1}: {2}'.format(regn1,regn2,session))
df = pd.DataFrame(columns=colnames)

for subject in subjects:
    print subject
    regnconns = {}
    for session in sessions:
        print subject, session
        regn_corrmat = pd.read_csv(join(sink_dir, session, subject, '{0}_yeo7_regn_corrmat.csv'.format(subject)), index_col=0, header=0)
        for regn1 in yeo_7_regn_labels:
            for regn2 in yeo_7_regn_labels:
                regnconns['{0}, {1}: {2}'.format(regn1,regn2,session)] = regn_corrmat[regn1][regn2]
    regnconnser = pd.Series(regnconns, name=subject)
    print regnconnser
    df[subject] = regnconnser
df.to_csv(join(sink_dir, 'out_yeo7_regn_conn.csv'))
