#!/home/data/nbc/data-analysis/env/bin/python
# performs gclda functional decoding on a continuous map
# last edited 03/27/17
# jbartley

# Imports
from os.path import join
import matplotlib.pyplot as plt

import nibabel as nib
from nilearn import plotting

from gclda.model import Model
from gclda.decode import decode_continuous
from gclda.utils import get_resource_path


# Load model and initialize decoder
model_file = join('/home/data/nbc/tools/gclda/data/models/', 'Neurosynth2015Filtered2',
                  'model_200topics_2015Filtered2_10000iters.pklz')
model = Model.load(model_file)

# Read in image to decode
file_to_decode = '/home/data/nbc/physics-learning/data/group-level/fci/fci-fullmodel_phys-cntrl_c123456_vthresh_p001_cthresh_p05.gfeat/cope1.feat/stats/zstat1.nii.gz'
#'/home/data/nbc/physics-learning/data/group-level/fci/fci-post-pre_phys-cntrl_c123456_vtrhes_p001_cthres_p05.gfeat/cope1.feat/stats/zstat2.nii.gz'
img_to_decode = nib.load(file_to_decode)

# Decode ROI
df, topic_weights = decode_continuous(model, img_to_decode)

# Get associated terms
df = df.sort_values(by='Weight', ascending=False)
print(df.head(10))
df.to_csv('gclda_fci_post-pre.csv', index_label='Term')

# Plot topic weights
fig2, ax2 = plt.subplots()
ax2.plot(topic_weights)
ax2.set_xlabel('Topic #')
ax2.set_ylabel('Weight')
fig2.show()
