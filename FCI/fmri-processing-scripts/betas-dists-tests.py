import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
from os import path
from scipy import stats
import statsmodels.stats.multitest as multi

d = {}
p = []
datadir = '/home/data/nbc/physics-learning/physics-learning-fci/'

df = pd.read_csv(path.join(datadir, 'fci_betas.csv'))
df.rename(columns={'Unnamed: 0': 'subject'}, inplace=True)
for mod in df['model'].unique():
	sub_df = df.loc[df['model']==mod]
	d.update({mod: sub_df})
	sub_df = sub_df.melt(id_vars=['subject', 'model'], value_vars=['ACC', 'lHIPP', 'RSP',
                                     'LDLPFC', 'LPostPar'], value_name='Beta', var_name='ROI')
	fig, ax = plt.subplots()
	sns.violinplot(data=sub_df, x='ROI', y='Beta')
	fig.show()

# hypothesis 1
p.append(stats.ttest_1samp(d['diff']['ACC'], 0)[1])
p.append(stats.ttest_1samp(d['diff']['LDLPFC'], 0)[1])

# hypothesis 2
p.append(stats.ttest_1samp(d['reas']['ACC'], 0)[1])
p.append(stats.ttest_1samp(d['reas']['LPostPar'], 0)[1])
p.append(stats.ttest_1samp(d['reas']['LDLPFC'], 0)[1])
p.append(stats.ttest_1samp(d['reas']['lHIPP'], 0)[1])

# hypothesis 3
p.append(stats.ttest_1samp(d['gut']['RSP'], 0)[1])

# hypothesis 4
p.append(stats.ttest_1samp(d['acc']['ACC'], 0)[1])
p.append(stats.ttest_1samp(d['acc']['LPostPar'], 0)[1])
p.append(stats.ttest_1samp(d['acc']['LDLPFC'], 0)[1])
p.append(stats.ttest_1samp(d['acc']['lHIPP'], 0)[1])
p.append(stats.ttest_1samp(d['acc']['RSP'], 0)[1])

print(multi.multipletests(p, alpha = 0.05, method='holm'))
