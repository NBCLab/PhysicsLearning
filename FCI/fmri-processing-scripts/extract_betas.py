"""
Extract betas for physics-learning FCI parametric modulation analysis.
"""
import os
from os.path import join

import numpy as np
import pandas as pd
import nibabel as nib
from nilearn.masking import apply_mask

model_files = ['acc_0var_paths.txt', 'diff_0var_paths.txt',
               'reas_0var_paths.txt', 'gut_0var_paths.txt']


mask_dir = '/home/data/nbc/physics-learning/physics-learning/para-mod-analysis/'
mask_files = ['ACC_10mm.nii.gz', 'lHIPP_10mmroi.nii.gz', 'RSP_10mmroi.nii.gz',
              'LDLPFC_10mm.nii.gz', 'LPostPar_10mm.nii.gz']

dfs = []
for model_file in model_files:
    model_name = model_file.split('_')[0]

    in_df = pd.read_csv(model_file, header=None)
    native_cope_files = in_df[0].tolist()
    subjects = [ci.split('/')[7] for ci in native_cope_files]
    
    data_imgs = []
    for i_sub, data_file in enumerate(native_cope_files):
        # Switch to MNI space images for first levels
        data_file = data_file.replace('-5mm.feat/stats/', '-5mm.feat/reg_standard/stats/')
        data_img = nib.load(data_file)
        data_imgs.append(data_img)

    temp_dfs = []
    for j_mask, mask_file in enumerate(mask_files):
        mask = join(mask_dir, mask_file)
        mask_name = mask_file.split('_')[0]
        mask_img = nib.load(mask)
        mask_betas = apply_mask(imgs=data_imgs, mask_img=mask_img)
        mask_betas = mask_betas.mean(axis=1)

        df = pd.DataFrame(index=subjects, columns=[mask_name],
                          data=mask_betas.T)
        temp_dfs.append(df)
    temp_df = pd.concat(temp_dfs, axis=1)
    temp_df['model'] = model_name
    dfs.append(temp_df)
df2 = pd.concat(dfs, axis=0)
df2.to_csv('fci_betas.csv')
