# Imports
from os.path import join
import matplotlib.pyplot as plt

import nibabel as nib
from nilearn import plotting

from gclda.model import Model
from gclda.decode import decode_continuous
from gclda.utils import get_resource_path

# Files to decode
f_in = '/home/data/nbc/physics-learning/data/group-level/fci/fci-preOnly_phys-cntrl_c123456_vthres_p001_cthres_p05.gfeat/cope1.feat/stats/zstat1.nii.gz'

# Output filename
f_out = 'gclda_fci_preOnly_phys-cntrl.csv'

# Load model and initialize decoder
model_file = join('/home/data/nbc/tools/gclda/data/models/', 'Neurosynth2015Filtered2',
                  'model_200topics_2015Filtered2_10000iters.pklz')
model = Model.load(model_file)

# Read in image to decode
file_to_decode = f_in
img_to_decode = nib.load(file_to_decode)
#fig = plotting.plot_stat_map(img_to_decode, display_mode='z',
#                             threshold=3.290527,
#                             cut_coords=[-28, -4, 20, 50])

# Decode ROI
df, topic_weights = decode_continuous(model, img_to_decode)

# Get associated terms
df = df.sort_values(by='Weight', ascending=False)
print(df.head(10))
df.to_csv(f_out, index_label='Term')

# Plot topic weights
fig2, ax2 = plt.subplots()
ax2.plot(topic_weights)
ax2.set_xlabel('Topic #')
ax2.set_ylabel('Weight')
fig2.show()
