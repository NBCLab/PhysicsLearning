# Run two-way repeated reasures ANOVA on FCI Phases RT
# Rhe same set of subjects have values for each of two conditions.
#     - IVs: Condition (FCI, Control; the repeated measure), Group (Group A, Group B, Group C; the independent groups)
#     - DV: RT
#
# Author: Taylor Salo, modified by Jessica Bartley

# Import relevant libraries
library('nlme')
library('multcomp')
library('tidyr')
library('emmeans')

rm(list=ls())

# Location of values
# If I want to only test accuracy and RT (all phases)
f = '/Users/jessicabartley/Documents/JessicaBartley/Documents/FIU/Research/Writing/FCI_post/fciResponseHetergeneity/group_rt_cond.txt'

# Read in data
myData <- read.csv(file = f, sep = '\t')

# Set columns as factors
myData <- within(myData, {
  subject <- factor(Subject)
  condition <- factor(Condition)
  group <- factor(Group)
})

# Sort by subject (unnecessary)
myData <- myData[order(myData$subject), ]
head(myData)

# Get mean across observations for each combo
myData.mean <- aggregate(myData$RT,
                         by=list(myData$subject,
                                 myData$condition,
                                 myData$group),
                         FUN='mean')
colnames(myData.mean) <- c("subject", "condition", "group", "RT")
myData.mean <- myData.mean[order(myData.mean$subject), ]
head(myData.mean)

# Sort of from https://stats.stackexchange.com/a/13816
# and https://stats.stackexchange.com/a/23014
# and https://stats.stackexchange.com/a/10909
# also referenced https://www.r-bloggers.com/two-way-anova-with-repeated-measures/ and https://m-clark.github.io/docs/mixedModels/anovamixed.html#more-mixed-model-repeated-measures-anova-equivalence
# http://dwoll.de/rexrepos/posts/anovaMixed.html#two-way-repeated-measures-anova-rbf-pq-design
alpha = 0.05

count=0
group_e=0
condition_e=0

# IV: Condition (FCI, Control), Group (Group A, Group B, Group C) DV: RT
print('-----------------------------------------------------------------------')
model = lme(RT ~ group*condition, random=~1 | subject, method="ML", data=myData.mean)
modelAnova = anova(model)
print(modelAnova)
p = modelAnova['group:condition', 'p-value']
if(p < alpha){
  print('--Two-way interaction between group and condition is significant.--')
  print('Focus on interpreting *simple* main effects of group and condition.')
  print(pairs(emmeans(model, ~ group*condition)))
} else{
  print('--Two-way interaction is not significant. Running Main Effects.--')
  # testing main effect of group
  p = modelAnova['group', 'p-value']
  if(p < alpha){
    print('--Main effect of group is significant.--')
    print(summary(glht(model, linfct=mcp(group="Tukey")),
                  test=adjusted(type="holm")))
  } else(group_e=1)
  # testing main effect of condition
  p = modelAnova['condition', 'p-value']
  if(p < alpha){
    print('--Main effect of condition is significant.--')
    print(summary(glht(model, linfct=mcp(condition="Tukey")),
                  test=adjusted(type="holm")))
  } else(condition_e=1)
  if(group_e == 1 && condition_e == 1){
    print('no significnt main effects')
  }
}

# conduct paired samples t-test for each group separately
# H0: FCI RT - Control FT = 0 for each group
for(i in unique(myData.mean$group)){
  print(i)
  data = myData.mean[myData.mean$group==i,]
  data = reshape(data, idvar = "subject", timevar = "condition", direction = "wide")
  print(t.test(data$RT.FCI, 
         data$RT.Control, 
         paired=TRUE, 
         conf.level=0.95))
  print('-----------------------------------------------------------------------')
}