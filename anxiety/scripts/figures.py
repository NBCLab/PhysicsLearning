
# coding: utf-8

# In[1]:


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


#less important for plotting
from glob import glob
from os.path import join
import statsmodels.formula.api as sm
from sklearn.linear_model import LinearRegression
import scipy, scipy.stats
from statsmodels.sandbox.stats.multicomp import multipletests


# In[2]:


def calculate_pvalues(df):
    from scipy.stats import pearsonr
    df = df.dropna()._get_numeric_data()
    dfcols = pd.DataFrame(columns=df.columns)
    pvalues = dfcols.transpose().join(dfcols, how='outer')
    for r in df.columns:
        for c in df.columns:
            pvalues[r][c] = round(pearsonr(df[r], df[c])[1], 4)
    return pvalues


# In[3]:


data_dir = '/Users/Katie/Dropbox/Projects/physics-anxiety/anxiety_results/Results_06-11-18 copy/'
fig_dir = '/Volumes/GoogleDrive/My Drive/salience-anxiety-graph-theory/figures/'
print(join(data_dir, 'All data_6-11-18.xlsx'))


# In[4]:


df = pd.read_csv('/Users/Katie/Dropbox/Projects/physics-anxiety/anxiety_results/Results_06-11-18 copy/All-data_6-11-18.csv', index_col=0, header=0)


# In[5]:


male_df_nofreshmen = pd.read_csv(join(data_dir, 'Male_alldata_06-26-18_no_freshmen.csv'))
female_df_nofreshmen = pd.read_csv(join(data_dir, 'Female_all_data_06-06-18_no freshmen.csv'))


# In[6]:


df = df.replace({'Gender': {2: 'Female'}})
df = df.replace({'Gender': {1: 'Male'}})


# In[7]:


df.index


# In[8]:


kurtosis = df.kurtosis(axis=0, skipna=True)
mean = df.mean(axis=0, skipna=True)
skew = df.skew(axis=0, skipna=True)
median = df.median(axis=0, skipna=True)
stdev = df.std(axis=0, skipna=True)
descriptives = pd.concat([mean, stdev, median, skew, kurtosis], axis=1)
#descriptives.to_csv('{0}/pre-descriptives.csv'.format(data_dir), sep=',')


# In[9]:


pre_post_braincorr = np.empty((3,3), dtype=float)


# In[10]:


pre_post_braincorr[0,1] = np.average(df['Pre_DMN_SN'])
pre_post_braincorr[1,0] = np.average(df['Post_DMN_SN'])

pre_post_braincorr[2,0] = np.average(df['Pre_CEN_DMN'])
pre_post_braincorr[0,2] = np.average(df['Post_CEN_DMN'])

pre_post_braincorr[2,1] = np.average(df['Pre_SN_CEN'])
pre_post_braincorr[1,2] = np.average(df['Post_SN_CEN'])


# In[11]:


pre_post_braincorr


# In[12]:


corrfonty = {'fontsize': 10,
             'fontweight': 'regular',
             'verticalalignment': 'center',
             'horizontalalignment': 'right'}
corrfontx = {'fontsize': 10,
             'fontweight': 'regular',
             'verticalalignment': 'top',
             'horizontalalignment': 'center'}


# In[13]:


fig,ax = plt.subplots(figsize=(6,5))
ax = sns.heatmap(pre_post_braincorr, annot=True, linewidths=0.5, cmap='summer', vmin=-0.21, vmax=0.61, 
                 cbar_kws={'ticks': [0.6, 0.4, 0.2, 0, -0.2]})
ax.set_yticklabels(['Default Mode', 'Salience', 'Central Executive'], fontdict=corrfonty)
ax.set_xticklabels(['Default Mode', 'Salience', 'Central Executive'], fontdict=corrfontx)
#fig.savefig('/Users/Katie/Dropbox/Projects/physics-anxiety/all-subj-corrmat.png', dpi=300)


# In[14]:


fig,ax = plt.subplots(figsize=(6,4))
ax = sns.distplot(df['Pre_DMN_SN'], hist=False, label='DMN-SN (pre)')
ax = sns.distplot(df['Post_DMN_SN'], hist=False, label='DMN-SN (post)')
ax = sns.distplot(df['Pre_CEN_DMN'], hist=False, label='DMN-CEN (pre)')
ax = sns.distplot(df['Post_CEN_DMN'], hist=False, label='DMN-CEN (post)')
ax = sns.distplot(df['Pre_SN_CEN'], hist=False, label='SN-CEN (pre)')
ax = sns.distplot(df['Post_SN_CEN'], hist=False, label='SN-CEN (post)')
#fig.savefig('/Users/Katie/Dropbox/Projects/physics-anxiety/corrmat-dist.png', dpi=300)


# In[15]:


fig,ax = plt.subplots(figsize=(4,4))
ax = sns.distplot(df['Pre_DMN_SN'], hist=False, label='Pre')
ax = sns.distplot(df['Post_DMN_SN'], hist=False, label='Post')
#fig.savefig('/Users/Katie/Dropbox/Projects/physics-anxiety/dmn-sn-dist.png', dpi=300)


# In[16]:


fig,ax = plt.subplots(figsize=(4,4))
ax = sns.distplot(df['Pre_CEN_DMN'], hist=False, label='Pre')
ax = sns.distplot(df['Post_CEN_DMN'], hist=False, label='Post')
#fig.savefig('/Users/Katie/Dropbox/Projects/physics-anxiety/dmn-cen-dist.png', dpi=300)


# In[17]:


fig,ax = plt.subplots(figsize=(4,4))
ax = sns.distplot(df['Pre_SN_CEN'], hist=False, label='Pre')
ax = sns.distplot(df['Post_SN_CEN'], hist=False, label='Post')
#fig.savefig('/Users/Katie/Dropbox/Projects/physics-anxiety/sn-cen-dist.png', dpi=300)


# In[18]:


df_ladies = df[df['Gender'] == 'Female']
df_dudes = df[df['Gender'] == 'Male']


# In[19]:


df_anx_pre_gender = df.melt(id_vars='Gender', value_vars=['Pre_SNA', 'Pre_BK', 'Pre_ScA', 'Pre_MA'], 
                            var_name='Science_Anxieties_Pre')
df_anx_post_gender = df.melt(id_vars='Gender', value_vars=['Post_SNA', 'Post_BK', 'Post_ScA', 'Post_MA'], 
                            var_name='Science_Anxieties_Post')


# ## Figure 1: pre < post, science & beck anxiety, women & men
# Four anxieties, two swarms per (pre/post), two colors (gender)
# <br>
# Make a version without the swarms, with a thing instead.

# In[21]:


l_purp = '#c364c5'
d_purp = '#7851a9'
l_green = '#71bc78'
d_green = '#17806d'

crayons = [l_purp, d_purp, l_green, d_green]
crayons_l = [crayons[0], crayons[2]]
crayons_d = [crayons[1], crayons[3]]
sns.palplot(sns.color_palette(crayons))

genders = [(0.812, 0.20, 0.551), 
           (0.349, 0.416, 1)]
genders_l = [(0.961, 0.282, 0.676),
             (0.482, 0.529, 1)]


# In[22]:


crayons = sns.crayon_palette(['Fuchsia', 'Fern'])
dark_crayons = sns.crayon_palette(['Royal Purple', 'Tropical Rain Forest'])

ladies = sns.diverging_palette(280.2, 327.8, s=85, l=50, n=200)
dudes = sns.diverging_palette(200, 263.2, s=85, l=50, n=200)
#razzmatazz and jazzberry
#tropical rain forest and cerulean


# In[23]:


fig, ax = plt.subplots(1, ncols=2, figsize=(15, 5), sharey=True)
g = sns.swarmplot(x="Science_Anxieties_Pre", y="value", hue="Gender", dodge=True, 
                  data=df_anx_pre_gender, palette=crayons_l, size=5, ax=ax[0])
g = sns.swarmplot(x="Science_Anxieties_Post", y="value", hue="Gender", dodge=True, 
                  data=df_anx_post_gender, palette=crayons_l, size=5, ax=ax[1])


# In[24]:


#want new df with science anxiety + gender, annotated by pre + post
#############################
###### STD SCORES ###########
#############################
df_sca = df.melt(id_vars='Gender', value_vars=['Pre_ScA', 'Post_ScA'],
                 var_name='Science Anxiety')
df_sca.replace(to_replace='Pre_ScA', value='Pre', inplace=True)
df_sca.replace(to_replace='Post_ScA', value='Post', inplace=True)

#want new df with science anxiety + gender, annotated by pre + post
df_ma = df.melt(id_vars='Gender', value_vars=['Pre_MA', 'Post_MA'],
                 var_name='Math Anxiety')
df_ma.replace(to_replace='Pre_MA', value='Pre', inplace=True)
df_ma.replace(to_replace='Post_MA', value='Post', inplace=True)

#want new df with science anxiety + gender, annotated by pre + post
df_sna = df.melt(id_vars='Gender', value_vars=['Pre_SNA', 'Post_SNA'],
                 var_name='Spatial Navigation Anxiety')
df_sna.replace(to_replace='Pre_SNA', value='Pre', inplace=True)
df_sna.replace(to_replace='Post_SNA', value='Post', inplace=True)

#want new df with science anxiety + gender, annotated by pre + post
df_bk = df.melt(id_vars='Gender', value_vars=['Pre_BK', 'Post_BK'],
                 var_name='Beck Anxiety')
df_bk.replace(to_replace='Pre_BK', value='Pre', inplace=True)
df_bk.replace(to_replace='Post_BK', value='Post', inplace=True)


# ## 9/14: Redo with the max (+) colors from Figures 2 & 3

# In[25]:


#want new df with science anxiety + gender, annotated by pre + post
#############################
###### RAW SCORES ###########
#############################
df_sca = df.melt(id_vars='Gender', value_vars=['Pre_ScA_raw', 'Post_ScA_raw'],
                 var_name='Science Anxiety')
df_sca.replace(to_replace='Pre_ScA_raw', value='Pre', inplace=True)
df_sca.replace(to_replace='Post_ScA_raw', value='Post', inplace=True)

#want new df with science anxiety + gender, annotated by pre + post
df_ma = df.melt(id_vars='Gender', value_vars=['Pre_MA_raw', 'Post_MA_raw'],
                 var_name='Math Anxiety')
df_ma.replace(to_replace='Pre_MA_raw', value='Pre', inplace=True)
df_ma.replace(to_replace='Post_MA_raw', value='Post', inplace=True)

#want new df with science anxiety + gender, annotated by pre + post
df_sna = df.melt(id_vars='Gender', value_vars=['Pre_SNA_raw', 'Post_SNA_raw'],
                 var_name='Spatial Navigation Anxiety')
df_sna.replace(to_replace='Pre_SNA_raw', value='Pre', inplace=True)
df_sna.replace(to_replace='Post_SNA_raw', value='Post', inplace=True)

#want new df with science anxiety + gender, annotated by pre + post
df_bk = df.melt(id_vars='Gender', value_vars=['Pre_BK_raw', 'Post_BK_raw'],
                 var_name='Beck Anxiety')
df_bk.replace(to_replace='Pre_BK_raw', value='Pre', inplace=True)
df_bk.replace(to_replace='Post_BK_raw', value='Post', inplace=True)


# In[26]:


fig,ax = plt.subplots(ncols=2, nrows=2, figsize=(20, 15), sharex=False, sharey=False, squeeze=True)
mksz = 8

sns.swarmplot(x="Science Anxiety", y="value", hue="Gender", data=df_sca, 
              palette=crayons_l, ax=ax[0][0], size=mksz, dodge=True)
ax[0][0].set_ylim(-1,50)
sns.swarmplot(x="Math Anxiety", y="value", hue="Gender", data=df_ma, 
              palette=crayons_l, ax=ax[1][0], size=mksz, dodge=True)
ax[1][0].set_ylim(-3,120)
sns.swarmplot(x="Spatial Navigation Anxiety", y="value", hue="Gender", data=df_sna, 
              palette=crayons_l, ax=ax[0][1], size=mksz, dodge=True)
ax[0][1].set_ylim(-0.5,22)
sns.swarmplot(x="Beck Anxiety", y="value", hue="Gender", data=df_bk, 
              palette=crayons_l, ax=ax[1][1], size=mksz, dodge=True)
ax[1][1].set_ylim(-2,70)

sns.pointplot(x="Science Anxiety", y="value", hue="Gender", data=df_sca, palette=crayons_d, ax=ax[0][0], size=mksz)
sns.pointplot(x="Math Anxiety", y="value", hue="Gender", data=df_ma, palette=crayons_d, ax=ax[1][0], size=mksz)
sns.pointplot(x="Spatial Navigation Anxiety", y="value", hue="Gender", data=df_sna, palette=crayons_d, ax=ax[0][1], size=mksz)
sns.pointplot(x="Beck Anxiety", y="value", hue="Gender", data=df_bk, palette=crayons_d, ax=ax[1][1], size=mksz)

#fig.savefig('/Users/Katie/Dropbox/Projects/physics-anxiety/figures/figure1_rawscores-pg.png', dpi=300)


# ## Figure 2.  Changes in anxiety correlated with changes in connectivity
# Making the glass brains for the figure.

# In[27]:


#maybe change to match
ladies = sns.diverging_palette(306.7, 327.8, s=90, l=45, n=200)
dudes = sns.diverging_palette(173.4, 263.2, s=90, l=45, n=200)


# In[36]:


from nilearn import plotting, datasets, surface
fsaverage = datasets.fetch_surf_fsaverage()

dmn = '/Users/Katie/Dropbox/Katie and Angie/2011 BrainMap ICA Maps/18-network-parcellation/comp13-bin.nii.gz'
cen = '/Users/Katie/Dropbox/Katie and Angie/2011 BrainMap ICA Maps/cen_combo.nii.gz'
sal = '/Users/Katie/Dropbox/Katie and Angie/2011 BrainMap ICA Maps/18-network-parcellation/comp4-bin.nii.gz'


# In[37]:


contrast_colors = sns.blend_palette(['#ff4c80', '#00a572'], n_colors=2, as_cmap=True)
color1 = sns.light_palette("#ff467e", as_cmap=True)
color2 = sns.light_palette("#00efd8", as_cmap=True)
color3 = sns.light_palette("#cedf3f", as_cmap=True)


# In[38]:


dmn_html = plotting.view_img_on_surf(dmn, threshold=0.9, cmap=color1)
dmn_html.save_as_html('dmn_surf.html')
cen_html = plotting.view_img_on_surf(cen, threshold=0.9, cmap=color2)
cen_html.save_as_html('cen_surf.html')
sal_html = plotting.view_img_on_surf(sal, threshold=0.9, cmap=color3)
sal_html.save_as_html('sal_surf.html')


# In[40]:


#making figure 2 heatmaps
fig2_df = df.drop(columns=['Cohort', 'GPA.PreSem', 'Phy48Grade', 'AgeOnScanDate',
                           'Pre_SNA', 'Pre_BK', 'Pre_ScA', 'Pre_MA', 'Pre_STEMcomposite',
                           'Post_SNA', 'Post_BK', 'Post_ScA', 'Post_MA', 'Post_STEMcomposite',
                           'Post_Clustering', 'Pre_Clustering',
                           'Post_Efficiency', 'Pre_Efficiency',
                           'Pre_BK_Sq', 'Post_BK_Sq', 'Pre_SNA_Sq',
                           'Pre_ScA_Sq', 'Post_ScA_Sq', 'Pre_MA_Sq', 'Post_MA_Sq', 
                           'Clustering_diff', 'Efficiency_diff',
                           'filter_$', 'CEN_DMN_diff_male',
                           'Clustering_diff_male', 'DMN_SN_diff_male', 'Efficiency_diff_male',
                           'SN_CEN_diff_male', 'CEN_DMN_diff_female', 'Clustering_diff_female',
                           'DMN_SN_diff_female', 'Efficiency_diff_female', 'SN_CEN_diff_female',
                           'SNA_diff_male_raw', 'BK_diff_male_raw', 'ScA_diff_male_raw',
                           'MA_diff_male_raw', 'SNA_diff_female_raw', 'BK_diff_female_raw',
                           'ScA_diff_female_raw', 'MA_diff_female_raw', 'SNA_diff_male',
                           'BK_diff_male', 'ScA_diff_male', 'MA_diff_male'])


# In[41]:


fig2_df.keys()


# In[42]:


m2_df = fig2_df[fig2_df['Gender'] == 'Male']
f2_df = fig2_df[fig2_df['Gender'] == 'Female']


# In[43]:


m2_corr = m2_df.corr(method='pearson')
fig,ax = plt.subplots(figsize=(20,15))
ax = sns.heatmap(m2_corr, cmap=dudes, vmax=0.5, vmin=-0.5)
#fig.savefig('/Volumes/GoogleDrive/My Drive/salience-anxiety-graph-theory/figures/fig2-male.png', dpi=300)


# In[44]:


f2_corr = f2_df.corr(method='pearson')
fig,ax = plt.subplots(figsize=(20,15))
ax = sns.heatmap(f2_corr, cmap=ladies, vmin=-1, vmax=1)
#fig.savefig('/Volumes/GoogleDrive/My Drive/salience-anxiety-graph-theory/figures/fig2-female.png', dpi=300)


# ## 9/14: exclude freshmen from GPA correlations!!!
# Send Angie a no-freshmen GPA corrmat.

# In[45]:


#what's the question we're asking? 
#is it "do brain measures contribute to explained vairance in student oucomes by anxiety?" 
#do brain measures explain anxiety?
#do brain measures + anxiety explain poor student outcomes?
#does anxeity explain poor student outcomes?


# ## Figure 3. Relationships between pre-course anxiety and outcomes

# In[46]:


f_nofresh = female_df_nofreshmen.drop(columns=['Physics_ID', 'Cohort', 'Gender', 'Phy48Grade',
       'AgeOnScanDate',
       'Pre_STEMcomposite',
       'Post_STEMcomposite', 'Post_CEN_DMN', 'Pre_CEN_DMN', 'Post_Clustering',
       'Pre_Clustering', 'Post_DMN_SN', 'Pre_DMN_SN', 'Post_Efficiency',
       'Pre_Efficiency', 'Post_SN_CEN', 'Pre_SN_CEN', 'CEN_DMN_diff', 'Clustering_diff', 'DMN_SN_diff',
       'Efficiency_diff', 'SN_CEN_diff'])


# In[47]:


m_nofresh = male_df_nofreshmen.drop(columns=['Physics_ID', 'Cohort', 'Gender', 'Phy48Grade',
       'AgeOnScanDate',
       'Pre_STEMcomposite',
       'Post_STEMcomposite', 'Post_CEN_DMN', 'Pre_CEN_DMN', 'Post_Clustering',
       'Pre_Clustering', 'Post_DMN_SN', 'Pre_DMN_SN', 'Post_Efficiency',
       'Pre_Efficiency', 'Post_SN_CEN', 'Pre_SN_CEN', 'CEN_DMN_diff', 'Clustering_diff', 'DMN_SN_diff',
       'Efficiency_diff', 'SN_CEN_diff'])


# In[48]:


#excluding freshmen
f_nofresh_corr = f_nofresh.corr(method='pearson')
fig,ax = plt.subplots(figsize=(20,15))
ax = sns.heatmap(f_nofresh_corr, cmap=ladies, vmax=0.5, vmin=-0.5)
#fig.savefig('/Volumes/GoogleDrive/My Drive/salience-anxiety-graph-theory/figures/fig3-female-GPA_ONLY.png', dpi=300)


# In[49]:


#excluding freshmen
m_nofresh_corr = m_nofresh.corr(method='pearson')
fig,ax = plt.subplots(figsize=(20,15))
ax = sns.heatmap(m_nofresh_corr, cmap=dudes, vmax=0.5, vmin=-0.5)
#fig.savefig('/Volumes/GoogleDrive/My Drive/salience-anxiety-graph-theory/figures/fig3-male-GPA_ONLY.png', dpi=300)


# In[50]:


green_div = sns.diverging_palette(228.5, 137.6, s=50, l=70, n=100)
purpl_div = sns.diverging_palette(254.2, 286.1, s=70, l=56, n=100)


# In[51]:


small_df = df.drop(columns=['Pre_STEMcomposite', 'Cohort', 'Post_STEMcomposite',
       'Post_CEN_DMN', 'Pre_CEN_DMN', 'Post_Clustering', 'Pre_Clustering',
       'Post_DMN_SN', 'Pre_DMN_SN', 'Post_Efficiency', 'Pre_Efficiency',
       'Post_SN_CEN', 'Pre_SN_CEN', 'Pre_BK_Sq', 'Post_BK_Sq', 'Pre_SNA_Sq',
       'Pre_ScA_Sq', 'Post_ScA_Sq', 'Pre_MA_Sq', 'Post_MA_Sq', 'Pre_SNA_raw',
       'Pre_BK_raw', 'Pre_ScA_raw', 'Pre_MA_raw', 'Post_BK_raw',
       'Post_ScA_raw', 'Post_MA_raw', 'Post_SNA_raw', 
       'CEN_DMN_diff', 'Clustering_diff', 'DMN_SN_diff', 'Efficiency_diff',
       'SN_CEN_diff', 'filter_$', 'CEN_DMN_diff_male',
       'Clustering_diff_male', 'DMN_SN_diff_male', 'Efficiency_diff_male',
       'SN_CEN_diff_male', 'CEN_DMN_diff_female', 'Clustering_diff_female',
       'DMN_SN_diff_female', 'Efficiency_diff_female', 'SN_CEN_diff_female',
       'SNA_diff_male_raw', 'BK_diff_male_raw', 'ScA_diff_male_raw',
       'MA_diff_male_raw', 'SNA_diff_female_raw', 'BK_diff_female_raw',
       'ScA_diff_female_raw', 'MA_diff_female_raw', 'SNA_diff_male',
       'BK_diff_male', 'ScA_diff_male', 'MA_diff_male', 'AgeOnScanDate'])


# In[52]:


m_df = small_df[small_df['Gender'] == 'Male']
f_df = small_df[small_df['Gender'] == 'Female']


# In[53]:


m_corr = m_df.corr(method='pearson')
fig,ax = plt.subplots(figsize=(20,15))
ax = sns.heatmap(m_corr, vmin=-0.5, vmax=0.5, cmap=dudes)
#fig.savefig('/Volumes/GoogleDrive/My Drive/salience-anxiety-graph-theory/figures/fig3-male-a.png', dpi=300)


# In[54]:


f_corr = f_df.corr(method='pearson')
fig,ax = plt.subplots(figsize=(20,15))
ax = sns.heatmap(f_corr, vmin=-0.5, vmax=0.5, cmap=ladies)
#fig.savefig('/Volumes/GoogleDrive/My Drive/salience-anxiety-graph-theory/figures/fig3-female-a.png', dpi=300)


# In[55]:


f_nofresh4 = female_df_nofreshmen.drop(columns=['Physics_ID', 'Cohort', 'Gender', 'Phy48Grade',
       'AgeOnScanDate',
       'Pre_STEMcomposite',
       'Post_STEMcomposite', 'Post_Clustering',
       'Pre_Clustering', 'Post_Efficiency',
       'Pre_Efficiency', 'Clustering_diff',
       'Efficiency_diff','Pre_SNA_raw', 'Pre_BK_raw', 'Pre_ScA_raw',
       'Pre_MA_raw', 'Post_BK_raw', 'Post_ScA_raw', 'Post_MA_raw',
       'Post_SNA_raw', 'BK_diff', 'MA_diff',
       'ScA_diff', 'SNA_diff'])


# In[56]:


m_nofresh4 = male_df_nofreshmen.drop(columns=['Physics_ID', 'Cohort', 'Gender', 'Phy48Grade',
       'AgeOnScanDate',
       'Pre_STEMcomposite',
       'Post_STEMcomposite', 'Post_Clustering',
       'Pre_Clustering', 'Post_Efficiency',
       'Pre_Efficiency', 'Clustering_diff',
       'Efficiency_diff','Pre_SNA_raw', 'Pre_BK_raw', 'Pre_ScA_raw',
       'Pre_MA_raw', 'Post_BK_raw', 'Post_ScA_raw', 'Post_MA_raw',
       'Post_SNA_raw', 'BK_diff', 'MA_diff',
       'ScA_diff', 'SNA_diff', 'SNA_diff_male', 'BK_diff_male', 'ScA_diff_male', 'MA_diff_male',
       'CEN_DMN_diff_male', 'Clustering_diff_male', 'DMN_SN_diff_male',
       'Efficiency_diff_male', 'SN_CEN_diff_male'])


# In[57]:


f_corr = f_nofresh4.corr(method='pearson')
fig,ax = plt.subplots(figsize=(20,15))
ax = sns.heatmap(f_corr, vmin=-0.5, vmax=0.5, cmap=ladies)
#fig.savefig('/Volumes/GoogleDrive/My Drive/salience-anxiety-graph-theory/figures/fig4-female-gpa.png', dpi=300)


# In[58]:


m_corr = m_nofresh4.corr(method='pearson')
fig,ax = plt.subplots(figsize=(20,15))
ax = sns.heatmap(m_corr, vmin=-0.5, vmax=0.5, cmap=dudes)
#fig.savefig('/Volumes/GoogleDrive/My Drive/salience-anxiety-graph-theory/figures/fig4-male-gpa.png', dpi=300)


# In[59]:


small_df = df.drop(columns=['Pre_STEMcomposite', 'GPA.PreSem', 'Cohort', 'Post_STEMcomposite',
       'Post_Clustering', 'Pre_Clustering',
       'Post_Efficiency', 'Pre_Efficiency', 'Pre_SNA', 'Pre_BK', 'Pre_ScA',
       'Pre_MA', 'Post_SNA', 'Post_BK', 'Post_ScA', 'Post_MA', 
       'Pre_BK_Sq', 'Post_BK_Sq', 'Pre_SNA_Sq',
       'Pre_ScA_Sq', 'Post_ScA_Sq', 'Pre_MA_Sq', 'Post_MA_Sq', 'Pre_SNA_raw',
       'Pre_BK_raw', 'Pre_ScA_raw', 'Pre_MA_raw', 'Post_BK_raw',
       'Post_ScA_raw', 'Post_MA_raw', 'Post_SNA_raw','ScA_diff', 'SNA_diff', 
       'Clustering_diff', 'Efficiency_diff',
       'filter_$', 'CEN_DMN_diff_male', 'BK_diff', 'MA_diff', 
       'Clustering_diff_male', 'DMN_SN_diff_male', 'Efficiency_diff_male',
       'SN_CEN_diff_male', 'CEN_DMN_diff_female', 'Clustering_diff_female',
       'DMN_SN_diff_female', 'Efficiency_diff_female', 'SN_CEN_diff_female',
       'SNA_diff_male_raw', 'BK_diff_male_raw', 'ScA_diff_male_raw',
       'MA_diff_male_raw', 'SNA_diff_female_raw', 'BK_diff_female_raw',
       'ScA_diff_female_raw', 'MA_diff_female_raw', 'SNA_diff_male',
       'BK_diff_male', 'ScA_diff_male', 'MA_diff_male', 'AgeOnScanDate'])


# In[60]:


m4_df = small_df[small_df['Gender'] == 'Male']
f4_df = small_df[small_df['Gender'] == 'Female']


# In[61]:


m_corr = m4_df.corr(method='pearson')
fig,ax = plt.subplots(figsize=(20,15))
ax = sns.heatmap(m_corr, vmin=-0.5, vmax=0.5, cmap=dudes)
#fig.savefig('/Volumes/GoogleDrive/My Drive/salience-anxiety-graph-theory/figures/fig4-male-grade.png', dpi=300)


# In[62]:


f_corr = f4_df.corr(method='pearson')
fig,ax = plt.subplots(figsize=(20,15))
ax = sns.heatmap(f_corr, vmin=-0.5, vmax=0.5, cmap=ladies)
#fig.savefig('/Volumes/GoogleDrive/My Drive/salience-anxiety-graph-theory/figures/fig4-female-grade.png', dpi=300)

