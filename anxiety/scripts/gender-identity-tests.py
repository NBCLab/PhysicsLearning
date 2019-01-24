
# coding: utf-8

# In[7]:


#numpy is numerical python, which lets us do math!
import numpy as np
#pandas is for reading in and manipulating dataframe
import pandas as pd
#matplotlib is a plotting library the originated in matlab
from matplotlib import pyplot as plt
#seaborn wraps around matplotlib so that we can make pretty plots more easliy
import seaborn as sns
#this little line of code lets us see the plots in the notebook
get_ipython().run_line_magic('matplotlib', 'inline')
#this uses seaborn (sns) to set the style for all the plots
sns.set_style(style='ticks')
sns.plotting_context(context='paper', font_scale=2)
from scipy.stats import norm


#less important for plotting
from os.path import join
from scipy.stats import spearmanr, pearsonr, ttest_ind, ttest_rel, mannwhitneyu


# In[2]:


data_dir = '/Users/Katie/Dropbox/Projects/physics-learning/data/'
anx_dir = '/Users/Katie/Dropbox/Projects/physics-anxiety/anxiety_results/Results_06-11-18 copy/'
out_dir = '/Users/Katie/Dropbox/Projects/physics-anxiety/data/'
fig_dir = '/Users/Katie/Dropbox/Projects/physics-anxiety/figures/'


# In[3]:


f_df = pd.read_csv(join(data_dir, 'rescored_gender_identity_female.csv'), index_col=0, header=[0,1])
m_df = pd.read_csv(join(data_dir, 'rescored_gender_identity_male.csv'), index_col=0, header=[0,1])


# In[4]:


f_df['1', 'Masculinity Pre'] = 6 - f_df['1', 'GID Pre']
f_df['2', 'Masculinity Post'] = 6 - f_df['2', 'GID Post']
m_df['1', 'Masculinity Pre'] = m_df['1', 'GID Pre']
m_df['2', 'Masculinity Post'] = m_df['2', 'GID Post']


# In[11]:


m_df['1', 'GID Pre'].mean(skipna=True)
m_df['1', 'GID Pre'].std(skipna=True)
m_df['2', 'GID Post'].mean(skipna=True)
m_df['2', 'GID Post'].std(skipna=True)

f_df['1', 'GID Pre'].mean(skipna=True)
f_df['1', 'GID Pre'].std(skipna=True)
f_df['2', 'GID Post'].mean(skipna=True)
f_df['2', 'GID Post'].std(skipna=True)

np.mean(m_df['1', 'GID Pre'] - m_df['2', 'GID Post'])

#do recalled gender identity scores vary significantly pre-post?
f_diff = ttest_rel(f_df['1', 'GID Pre'], f_df['2', 'GID Post'], nan_policy='omit')
m_diff = ttest_rel(m_df['1', 'GID Pre'], m_df['2', 'GID Post'], nan_policy='omit')

#how about between genders?
pre_diff = ttest_ind(f_df['1', 'GID Pre'], m_df['1', 'GID Pre'], nan_policy='omit')
post_diff = ttest_ind(f_df['2', 'GID Post'], m_df['2', 'GID Post'], nan_policy='omit')


# In[12]:


print('Pre > post, male: {0}\nPre > post, female: {1}\n\nFemale > male, pre: {2}\nFemale > male, post: {3}'.format(m_diff, f_diff, pre_diff, post_diff))


# In[13]:


df = pd.read_csv(join(anx_dir, 'All-data_6-11-18.csv'), header=0, index_col=0)


# In[14]:


subjects = list(set(df.index))
f_subj = list(set(df[df['Gender']==2].index))
m_subj = list(set(df[df['Gender']==1].index))


# In[15]:


gender_df = pd.concat((f_df.reindex(subjects).dropna(how='all'), m_df.reindex(subjects).dropna(how='all')), sort=True)


# In[23]:


pre_brain_vars = ['Pre_CEN_DMN', 'Pre_DMN_SN', 'Pre_SN_CEN']
post_brain_vars = ['Post_CEN_DMN', 'Post_DMN_SN', 'Post_SN_CEN']
pre_anx_vars = ['Pre_SNA_raw', 'Pre_ScA_raw', 'Pre_MA_raw', 'Pre_BK_raw']
post_anx_vars = ['Post_SNA_raw', 'Post_ScA_raw', 'Post_MA_raw', 'Post_BK_raw']
pre_vars = list(pre_brain_vars + pre_anx_vars)
post_vars = list(post_brain_vars + post_anx_vars)


# In[43]:


all_spearmanr = {}
all_pval = {}

for var in pre_vars:
    corr = spearmanr(df[var], gender_df['1','GID Pre'])
    all_spearmanr['{0} x GID, pre'.format(var)] = corr[0]
    all_pval['{0} x GID, pre'.format(var)] = corr[1]
    corr = spearmanr(df[var], gender_df['1','Masculinity Pre'])
    all_spearmanr['{0} x Masculinity, pre'.format(var)] = corr[0]
    all_pval['{0} x Masculinity, pre'.format(var)] = corr[1]

for var in post_vars:
    corr = spearmanr(df[var], gender_df['2','Masculinity Post'])
    all_spearmanr['{0} x GID, post'.format(var)] = corr[0]
    all_pval['{0} x GID, post'.format(var)] = corr[1]
    corr = spearmanr(df[var], gender_df['2','Masculinity Post'])
    all_spearmanr['{0} x Masculinity, post'.format(var)] = corr[0]
    all_pval['{0} x Masculinity, post'.format(var)] = corr[1]
    
f_spearmanr = {}
f_pval = {}
for var in pre_vars:
    corr = spearmanr(df.reindex(f_subj)[var], gender_df.reindex(f_subj)['1','GID Pre'])
    f_spearmanr['{0} x GID, pre'.format(var)] = corr[0]
    f_pval['{0} x GID, pre'.format(var)] = corr[1]
    corr = spearmanr(df.reindex(f_subj)[var], gender_df.reindex(f_subj)['1','Masculinity Pre'])
    f_spearmanr['{0} x Masculinity, pre'.format(var)] = corr[0]
    f_pval['{0} x Masculinity, pre'.format(var)] = corr[1]

for var in post_vars:
    corr = spearmanr(df.reindex(f_subj)[var], gender_df.reindex(f_subj)['2','GID Post'])
    f_spearmanr['{0} x GID, post'.format(var)] = corr[0]
    f_pval['{0} x GID, post'.format(var)] = corr[1]
    corr = spearmanr(df.reindex(f_subj)[var], gender_df.reindex(f_subj)['2','Masculinity Post'])
    f_spearmanr['{0} x Masculinity, post'.format(var)] = corr[0]
    f_pval['{0} x Masculinity, post'.format(var)] = corr[1]

m_spearmanr = {}
m_pval = {}
for var in pre_vars:
    corr = spearmanr(df.reindex(m_subj)[var], gender_df.reindex(m_subj)['1','GID Pre'])
    m_spearmanr['{0} x GID, pre'.format(var)] = corr[0]
    m_pval['{0} x GID, pre'.format(var)] = corr[1]
    corr = spearmanr(df.reindex(m_subj)[var], gender_df.reindex(m_subj)['1','Masculinity Pre'])
    m_spearmanr['{0} x Masculinity, pre'.format(var)] = corr[0]
    m_pval['{0} x Masculinity, pre'.format(var)] = corr[1]

for var in post_vars:
    corr = spearmanr(df.reindex(m_subj)[var], gender_df.reindex(m_subj)['2','GID Post'])
    m_spearmanr['{0} x GID, post'.format(var)] = corr[0]
    m_pval['{0} x GID, post'.format(var)] = corr[1]
    corr = spearmanr(df.reindex(m_subj)[var], gender_df.reindex(m_subj)['2','Masculinity Post'])
    m_spearmanr['{0} x Masculinity, post'.format(var)] = corr[0]
    m_pval['{0} x Masculinity, post'.format(var)] = corr[1]

pd.DataFrame([pd.Series(all_spearmanr, name='All r'), pd.Series(all_pval, name='All p(r)'),
              pd.Series(f_spearmanr, name='Female r'), pd.Series(f_pval, name='Female p(r)'),
              pd.Series(m_spearmanr, name='Male r'), pd.Series(m_pval, name='Male p(r)')]).T.to_csv(join(out_dir, 'gender_spearman_correlations.csv'))


# In[44]:


corr_diff = {}
p_corr_diff = {}

for var in pre_vars:
    corr1 = spearmanr(df.reindex(m_subj)[var], gender_df.reindex(m_subj)['1','GID Pre'])
    corr2 = spearmanr(df.reindex(f_subj)[var], gender_df.reindex(f_subj)['1','GID Pre'])
    z1 = np.arctanh(corr1[0])
    z2 = np.arctanh(corr2[0])

    Zobserved = (z1 - z2) / np.sqrt((1 / (len(m_subj) - 3)) + (1 / (len(f_subj) - 3)))
    print('Difference in corr {0} x gender identity in male, female: z = {1}, p = {2}'.format(var, Zobserved, norm.sf(abs(Zobserved))*2))
    corr_diff['{0} x GID, pre'.format(var)] = Zobserved
    p_corr_diff['{0} x GID, pre'.format(var)] = norm.sf(abs(Zobserved))*2
    
    corr1 = spearmanr(df.reindex(m_subj)[var], gender_df.reindex(m_subj)['1','Masculinity Pre'])
    corr2 = spearmanr(df.reindex(f_subj)[var], gender_df.reindex(f_subj)['1','Masculinity Pre'])
    z1 = np.arctanh(corr1[0])
    z2 = np.arctanh(corr2[0])

    Zobserved = (z1 - z2) / np.sqrt((1 / (len(m_subj) - 3)) + (1 / (len(f_subj) - 3)))
    print('Difference in corr {0} x masculinity in male, female: z = {1}, p = {2}'.format(var, Zobserved, norm.sf(abs(Zobserved))*2))
    corr_diff['{0} x Masculinity, pre'.format(var)] = Zobserved
    p_corr_diff['{0} x Masculinity, pre'.format(var)] = norm.sf(abs(Zobserved))*2
    
for var in post_vars:
    corr1 = spearmanr(df.reindex(m_subj)[var], gender_df.reindex(m_subj)['2','GID Post'])
    corr2 = spearmanr(df.reindex(f_subj)[var], gender_df.reindex(f_subj)['2','GID Post'])
    z1 = np.arctanh(corr1[0])
    z2 = np.arctanh(corr2[0])

    Zobserved = (z1 - z2) / np.sqrt((1 / (len(m_subj) - 3)) + (1 / (len(f_subj) - 3)))
    print('Difference in corr {0} x gender identity in male, female: z = {1}, p = {2}'.format(var, Zobserved, norm.sf(abs(Zobserved))*2))
    corr_diff['{0} x GID, pre'.format(var)] = Zobserved
    p_corr_diff['{0} x GID, pre'.format(var)] = norm.sf(abs(Zobserved))*2
    
    corr1 = spearmanr(df.reindex(m_subj)[var], gender_df.reindex(m_subj)['2','Masculinity Post'])
    corr2 = spearmanr(df.reindex(f_subj)[var], gender_df.reindex(f_subj)['2','Masculinity Post'])
    z1 = np.arctanh(corr1[0])
    z2 = np.arctanh(corr2[0])

    Zobserved = (z1 - z2) / np.sqrt((1 / (len(m_subj) - 3)) + (1 / (len(f_subj) - 3)))
    print('Difference in corr {0} x masculinity in male, female: z = {1}, p = {2}'.format(var, Zobserved, norm.sf(abs(Zobserved))*2))
    corr_diff['{0} x Masculinity, pre'.format(var)] = Zobserved
    p_corr_diff['{0} x Masculinity, pre'.format(var)] = norm.sf(abs(Zobserved))*2

pd.DataFrame([pd.Series(corr_diff, name='Z_diff'), 
              pd.Series(p_corr_diff, name='p(Z_diff)')]).T.to_csv(join(out_dir, 'sex_diff_gender_correlations.csv'))


# In[45]:


df.drop(['Cohort', 'GPA.PreSem', 'Phy48Grade', 'AgeOnScanDate',
       'Pre_SNA', 'Pre_BK', 'Pre_ScA', 'Pre_MA', 'Pre_STEMcomposite',
       'Post_SNA', 'Post_BK', 'Post_ScA', 'Post_MA', 'Post_STEMcomposite',
       'Post_Clustering', 'Pre_Clustering',
       'Post_Efficiency', 'Pre_Efficiency',
       'Pre_BK_Sq', 'Post_BK_Sq', 'Pre_SNA_Sq',
       'Pre_ScA_Sq', 'Post_ScA_Sq', 'Pre_MA_Sq', 'Post_MA_Sq', 'BK_diff', 'MA_diff',
       'CEN_DMN_diff', 'Clustering_diff', 'DMN_SN_diff', 'Efficiency_diff',
       'SN_CEN_diff', 'ScA_diff', 'SNA_diff', 'filter_$', 'CEN_DMN_diff_male',
       'Clustering_diff_male', 'DMN_SN_diff_male', 'Efficiency_diff_male',
       'SN_CEN_diff_male', 'CEN_DMN_diff_female', 'Clustering_diff_female',
       'DMN_SN_diff_female', 'Efficiency_diff_female', 'SN_CEN_diff_female',
       'SNA_diff_male_raw', 'BK_diff_male_raw', 'ScA_diff_male_raw',
       'MA_diff_male_raw', 'SNA_diff_female_raw', 'BK_diff_female_raw',
       'ScA_diff_female_raw', 'MA_diff_female_raw', 'SNA_diff_male',
       'BK_diff_male', 'ScA_diff_male', 'MA_diff_male'], axis=1, inplace=True)


# In[46]:


gid_df = pd.DataFrame(index=subjects)


# In[47]:


gid_df['Masculinity, pre'] = gender_df['1', 'Masculinity Pre']
gid_df['Masculinity, post'] = gender_df['2', 'Masculinity Post']
gid_df['GID, pre'] = gender_df['1', 'GID Pre']
gid_df['GID, post'] = gender_df['2', 'GID Post']


# In[48]:


small_df = pd.concat((df, gid_df), axis=1)


# In[49]:


post_df = small_df.drop(['Pre_CEN_DMN', 'Pre_DMN_SN',
                        'Pre_SN_CEN', 'Pre_SNA_raw', 'Pre_BK_raw', 'Pre_ScA_raw',
                        'Pre_MA_raw', 'Masculinity, pre', 'GID, pre'], axis=1)
pre_df = small_df.drop(['Post_CEN_DMN', 'Post_DMN_SN',
                         'Post_SN_CEN', 'Post_BK_raw', 'Post_ScA_raw', 'Post_MA_raw',
                         'Post_SNA_raw', 'Masculinity, post',
                         'GID, post'], axis=1)


# In[50]:


pre_df.replace({'Gender':{1:'Male', 2:'Female'}}, inplace=True)
post_df.replace({'Gender':{1:'Male', 2:'Female'}}, inplace=True)


# In[51]:


l_purp = '#c364c5'
d_purp = '#7851a9'
l_green = '#71bc78'
d_green = '#17806d'

crayons = [l_purp, d_purp, l_green, d_green]
crayons_l = [crayons[0], crayons[2]]
crayons_d = [crayons[1], crayons[3]]
sns.palplot(sns.color_palette(crayons))


# In[52]:


fig,ax = plt.subplots(nrows=4, ncols=4, figsize=(25,20), sharey=True)

g = sns.regplot(x="Pre_SNA_raw", y="Masculinity, pre", data=pre_df, ax=ax[0][0], color="0.5", marker='+')
g = sns.regplot(x="Pre_SNA_raw", y="GID, pre", data=pre_df, ax=ax[1][0], color="0.5", marker='+')
g = sns.regplot(x="Pre_ScA_raw", y="Masculinity, pre", data=pre_df, ax=ax[0][1], color="0.5", marker='+')
g = sns.regplot(x="Pre_ScA_raw", y="GID, pre", data=pre_df, ax=ax[1][1], color="0.5", marker='+')
g = sns.regplot(x="Pre_MA_raw", y="Masculinity, pre", data=pre_df, ax=ax[0][2], color="0.5", marker='+')
g = sns.regplot(x="Pre_MA_raw", y="GID, pre", data=pre_df, ax=ax[1][2], color="0.5", marker='+')
g = sns.regplot(x="Pre_BK_raw", y="Masculinity, pre", data=pre_df, ax=ax[0][3], color="0.5", marker='+')
g = sns.regplot(x="Pre_BK_raw", y="GID, pre",  data=pre_df, ax=ax[1][3], color="0.5", marker='+')

g = sns.scatterplot(x="Pre_SNA_raw", y="Masculinity, pre", data=pre_df, hue='Gender', palette=crayons_l, ax=ax[0][0], legend=False)
g = sns.scatterplot(x="Pre_SNA_raw", y="GID, pre", data=pre_df, hue='Gender', palette=crayons_l, ax=ax[1][0], legend=False)
g = sns.scatterplot(x="Pre_ScA_raw", y="Masculinity, pre", data=pre_df, hue='Gender', palette=crayons_l, ax=ax[0][1], legend=False)
g = sns.scatterplot(x="Pre_ScA_raw", y="GID, pre", data=pre_df, hue='Gender', palette=crayons_l, ax=ax[1][1], legend=False)
g = sns.scatterplot(x="Pre_MA_raw", y="Masculinity, pre", data=pre_df, hue='Gender', palette=crayons_l, ax=ax[0][2], legend=False)
g = sns.scatterplot(x="Pre_MA_raw", y="GID, pre", data=pre_df, hue='Gender', palette=crayons_l, ax=ax[1][2], legend=False)
g = sns.scatterplot(x="Pre_BK_raw", y="Masculinity, pre", data=pre_df, hue='Gender', palette=crayons_l, ax=ax[0][3], legend=False)
g = sns.scatterplot(x="Pre_BK_raw", y="GID, pre",  data=pre_df, hue='Gender', palette=crayons_l, ax=ax[1][3], legend=False)

g = sns.regplot(x="Post_SNA_raw", y="Masculinity, post", data=post_df, ax=ax[2][0], color="0.5", marker='+')
g = sns.regplot(x="Post_SNA_raw", y="GID, post", data=post_df, ax=ax[3][0], color="0.5", marker='+')
g = sns.regplot(x="Post_ScA_raw", y="Masculinity, post", data=post_df, ax=ax[2][1], color="0.5", marker='+')
g = sns.regplot(x="Post_ScA_raw", y="GID, post", data=post_df, ax=ax[3][1], color="0.5", marker='+')
g = sns.regplot(x="Post_MA_raw", y="Masculinity, post", data=post_df, ax=ax[2][2], color="0.5", marker='+')
g = sns.regplot(x="Post_MA_raw", y="GID, post", data=post_df, ax=ax[3][2], color="0.5", marker='+')
g = sns.regplot(x="Post_BK_raw", y="Masculinity, post", data=post_df, ax=ax[2][3], color="0.5", marker='+')
g = sns.regplot(x="Post_BK_raw", y="GID, post",  data=post_df, ax=ax[3][3], color="0.5", marker='+')

g = sns.scatterplot(x="Post_SNA_raw", y="Masculinity, post", data=post_df, hue='Gender', palette=crayons_l, ax=ax[2][0], legend=False)
g = sns.scatterplot(x="Post_SNA_raw", y="GID, post", data=post_df, hue='Gender', palette=crayons_l, ax=ax[3][0], legend=False)
g = sns.scatterplot(x="Post_ScA_raw", y="Masculinity, post", data=post_df, hue='Gender', palette=crayons_l, ax=ax[2][1], legend=False)
g = sns.scatterplot(x="Post_ScA_raw", y="GID, post", data=post_df, hue='Gender', palette=crayons_l, ax=ax[3][1], legend=False)
g = sns.scatterplot(x="Post_MA_raw", y="Masculinity, post", data=post_df, hue='Gender', palette=crayons_l, ax=ax[2][2], legend=False)
g = sns.scatterplot(x="Post_MA_raw", y="GID, post", data=post_df, hue='Gender', palette=crayons_l, ax=ax[3][2], legend=False)
g = sns.scatterplot(x="Post_BK_raw", y="Masculinity, post", data=post_df, hue='Gender', palette=crayons_l, ax=ax[2][3], legend=False)
g = sns.scatterplot(x="Post_BK_raw", y="GID, post",  data=post_df, hue='Gender', palette=crayons_l, ax=ax[3][3], legend=False)


# In[ ]:


fig.savefig(join(fig_dir, 'anxiety_by_gender.png'), dpi=300)


# In[53]:


fig,ax = plt.subplots(nrows=4, ncols=3, figsize=(20,20), sharey=True)
g = sns.regplot(x="Pre_CEN_DMN", y="Masculinity, pre", data=pre_df, ax=ax[0][0], color="0.5", marker='+')
g = sns.regplot(x="Pre_CEN_DMN", y="GID, pre", data=pre_df, ax=ax[1][0], color="0.5", marker='+')
g = sns.regplot(x="Pre_DMN_SN", y="Masculinity, pre", data=pre_df, ax=ax[0][1], color="0.5", marker='+')
g = sns.regplot(x="Pre_DMN_SN", y="GID, pre", data=pre_df, ax=ax[1][1], color="0.5", marker='+')
g = sns.regplot(x="Pre_SN_CEN", y="Masculinity, pre", data=pre_df, ax=ax[0][2], color="0.5", marker='+')
g = sns.regplot(x="Pre_SN_CEN", y="GID, pre", data=pre_df, ax=ax[1][2], color="0.5", marker='+')

g = sns.scatterplot(x="Pre_CEN_DMN", y="Masculinity, pre", data=pre_df, hue='Gender', palette=crayons_l, ax=ax[0][0], legend=False)
g = sns.scatterplot(x="Pre_CEN_DMN", y="GID, pre", data=pre_df, hue='Gender', palette=crayons_l, ax=ax[1][0], legend=False)
g = sns.scatterplot(x="Pre_DMN_SN", y="Masculinity, pre", data=pre_df, hue='Gender', palette=crayons_l, ax=ax[0][1], legend=False)
g = sns.scatterplot(x="Pre_DMN_SN", y="GID, pre", data=pre_df, hue='Gender', palette=crayons_l, ax=ax[1][1], legend=False)
g = sns.scatterplot(x="Pre_SN_CEN", y="Masculinity, pre", data=pre_df, hue='Gender', palette=crayons_l, ax=ax[0][2], legend=False)
g = sns.scatterplot(x="Pre_SN_CEN", y="GID, pre", data=pre_df, hue='Gender', palette=crayons_l, ax=ax[1][2], legend=False)

g = sns.regplot(x="Post_CEN_DMN", y="Masculinity, post", data=post_df, ax=ax[2][0], color="0.5", marker='+')
g = sns.regplot(x="Post_CEN_DMN", y="GID, post", data=post_df, ax=ax[3][0], color="0.5", marker='+')
g = sns.regplot(x="Post_DMN_SN", y="Masculinity, post", data=post_df, ax=ax[2][1], color="0.5", marker='+')
g = sns.regplot(x="Post_DMN_SN", y="GID, post", data=post_df, ax=ax[3][1], color="0.5", marker='+')
g = sns.regplot(x="Post_SN_CEN", y="Masculinity, post", data=post_df, ax=ax[2][2], color="0.5", marker='+')
g = sns.regplot(x="Post_SN_CEN", y="GID, post", data=post_df, ax=ax[3][2], color="0.5", marker='+')

g = sns.scatterplot(x="Post_CEN_DMN", y="Masculinity, post", data=post_df, hue='Gender', palette=crayons_l, ax=ax[2][0], legend=False)
g = sns.scatterplot(x="Post_CEN_DMN", y="GID, post", data=post_df, hue='Gender', palette=crayons_l, ax=ax[3][0], legend=False)
g = sns.scatterplot(x="Post_DMN_SN", y="Masculinity, post", data=post_df, hue='Gender', palette=crayons_l, ax=ax[2][1], legend=False)
g = sns.scatterplot(x="Post_DMN_SN", y="GID, post", data=post_df, hue='Gender', palette=crayons_l, ax=ax[3][1], legend=False)
g = sns.scatterplot(x="Post_SN_CEN", y="Masculinity, post", data=post_df, hue='Gender', palette=crayons_l, ax=ax[2][2], legend=False)
g = sns.scatterplot(x="Post_SN_CEN", y="GID, post", data=post_df, hue='Gender', palette=crayons_l, ax=ax[3][2], legend=False)


# In[ ]:


fig.savefig(join(fig_dir, 'brain_by_gender.png'), dpi=300)


# In[54]:


ladies = sns.diverging_palette(280, 327, s=85, l=50, n=200)
dudes = sns.diverging_palette(201, 263.2, s=85, l=50, n=200)


# In[55]:


fig,ax = plt.subplots(figsize=(25,20))
sns.heatmap(pre_df[pre_df['Gender'] == 'Female'].corr(), cmap=ladies, vmin=-0.5, vmax=0.5)
fig.savefig(join(fig_dir, 'pre_gender_heatmap_ladies.png'), dpi=300)


# In[ ]:


fig,ax = plt.subplots(figsize=(25,20))
sns.heatmap(post_df[post_df['Gender'] == 'Female'].corr(), cmap=ladies, vmin=-0.5, vmax=0.5)
fig.savefig(join(fig_dir, 'post_gender_heatmap_ladies.png'), dpi=300)


# In[ ]:


fig,ax = plt.subplots(figsize=(25,20))
sns.heatmap(pre_df[pre_df['Gender'] == 'Male'].corr(), cmap=dudes, vmin=-0.5, vmax=0.5)
fig.savefig(join(fig_dir, 'pre_gender_heatmap_dudes.png'), dpi=300)


# In[ ]:


fig,ax = plt.subplots(figsize=(25,20))
sns.heatmap(post_df[post_df['Gender'] == 'Male'].corr(), cmap=dudes, vmin=-0.5, vmax=0.5)
fig.savefig(join(fig_dir, 'post_gender_heatmap_dudes.png'), dpi=300)

