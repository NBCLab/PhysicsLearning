# Run two-way repeated reasures ANOVA on FCI Phases RT
# For each experimental condition, the same set of subjects have values for all conditions and phases.
# Thus, this script is for repeated measures over mulitple repeaded sessions (in this case, sequential phases)
#     - IVs: Condition (FCI, Control), Phase (Phase I, Phase II, Phase III)
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
f = '/Users/jessicabartley/Documents/JessicaBartley/Documents/FIU/Research/Writing/FCI_post/fciResponseHetergeneity/fci_rt_gender_class_matched_post.txt'

# Read in data
data_wide <- read.csv(file = f, sep = '\t')

myData <- gather(data_wide, ConditionAndPhase, RT, 
                        Mean.FCI.RT:Mean.Control.Screen3.RT, factor_key=TRUE)

fci_cols = c("Mean.FCI.RT","Mean.FCI.Screen1.RT","Mean.FCI.Screen2.RT","Mean.FCI.Screen3.RT")
control_cols = c("Mean.Control.RT","Mean.Control.Screen1.RT","Mean.Control.Screen2.RT","Mean.Control.Screen3.RT")
screen1_cols = c("Mean.FCI.Screen1.RT","Mean.Control.Screen1.RT")
screen2_cols = c("Mean.FCI.Screen2.RT","Mean.Control.Screen2.RT")
screen3_cols = c("Mean.FCI.Screen3.RT","Mean.Control.Screen3.RT")
allscreens_cols = c("Mean.FCI.RT","Mean.Control.RT")
myData$Condition <- rep(NA, nrow(myData))
myData$Phase <- rep(NA, nrow(myData))
for(i in fci_cols){
  myData[myData$ConditionAndPhase == i, ][, "Condition"] <- "FCI"
}
for(i in control_cols){
  myData[myData$ConditionAndPhase == i, ][, "Condition"] <- "Control"
}
for(i in screen1_cols){
  myData[myData$ConditionAndPhase == i, ][, "Phase"] <- "Phase I"
}
for(i in screen2_cols){
  myData[myData$ConditionAndPhase == i, ][, "Phase"] <- "Phase II"
}
for(i in screen3_cols){
  myData[myData$ConditionAndPhase == i, ][, "Phase"] <- "Phase III"
}
for(i in allscreens_cols){
  myData[myData$ConditionAndPhase == i, ][, "Phase"] <- "All Phases"
}

# Set columns as factors
myData <- within(myData, {
  subject <- factor(Subject)
  condition <- factor(Condition)
  phase <- factor(Phase)
})

# Sort by subject (unnecessary)
myData <- myData[order(myData$subject), ]
head(myData)

# Get mean across observations for each combo
myData.mean <- aggregate(myData$RT,
                         by=list(myData$subject,
                                 myData$condition,
                                 myData$phase),
                         FUN='mean')
colnames(myData.mean) <- c("subject", "condition", "phase", "RT")
myData.mean <- myData.mean[order(myData.mean$subject), ]
head(myData.mean)

phases_df<-myData.mean[!(myData.mean$phase=="All Phases"),]
allphases_df<-myData.mean[(myData.mean$phase=="All Phases"),]

# Sort of from https://stats.stackexchange.com/a/13816
# and https://stats.stackexchange.com/a/23014
# and https://stats.stackexchange.com/a/10909
# also referenced https://www.r-bloggers.com/two-way-anova-with-repeated-measures/ and https://m-clark.github.io/docs/mixedModels/anovamixed.html#more-mixed-model-repeated-measures-anova-equivalence
# http://dwoll.de/rexrepos/posts/anovaMixed.html#two-way-repeated-measures-anova-rbf-pq-design
alpha = 0.05

count=0
phase_e=0
condition_e=0

# Run it across Phasese I-III only (not all phases together).
# IV: Condition (FCI, Control), Phase (Phase I, Phase II, Phase III) DV: RT
print('-----------------------------------------------------------------------')
model = lme(RT ~ phase*condition, random=~1 | subject, method="ML", data=phases_df)
modelAnova = anova(model)
print(modelAnova)
p = modelAnova['phase:condition', 'p-value']
if(p < alpha){
  print('--Two-way interaction between phase and condition is significant.--')
  print('Focus on interpreting *simple* main effects of phase and condition.')
  print(pairs(emmeans(model, ~ phase*condition)))
} else{
  print('--Two-way interaction is not significant. Running Main Effects.--')
  # testing main effect of phase
  p = modelAnova['phase', 'p-value']
  if(p < alpha){
    print('--Main effect of phase is significant.--')
    print(summary(glht(model, linfct=mcp(phase="Tukey")),
                  test=adjusted(type="holm")))
  } else(phase_e=1)
  # testing main effect of condition
  p = modelAnova['condition', 'p-value']
  if(p < alpha){
    print('--Main effect of condition is significant.--')
    print(summary(glht(model, linfct=mcp(condition="Tukey")),
                  test=adjusted(type="holm")))
  } else(condition_e=1)
  if(phase_e == 1 && condition_e == 1){
    print('no significnt main effects')
  }
}

# conduct paired samples t-test for all phases across conditions
# H0: FCI RT - Control FT = 0 for all phases together
for(i in unique(allphases_df$phase)){
  print('-----------------------------------------------------------------------')
  print(i)
  data = myData.mean[myData.mean$phase==i,]
  data = reshape(data, idvar = "subject", timevar = "condition", direction = "wide")
  print(head(data))
  print(t.test(data$RT.FCI, 
               data$RT.Control, 
               paired=TRUE, 
               conf.level=0.95))
  print('-----------------------------------------------------------------------')
}

# get means across all phases and conditions
for(i in unique(myData.mean$phase)){
  print('-----------------------------------------------------------------------')
  data = myData.mean[myData.mean$phase==i,]
  data = reshape(data, idvar = "subject", timevar = "condition", direction = "wide")
  mean_control_rt = mean(data$RT.Control)
  mean_fci_rt = mean(data$RT.FCI)
  print(i)
  print('Mean FCI RT in sec')
  print(mean_fci_rt * 10^-3)
  print('Mean Control RT in sec')
  print(mean_control_rt * 10^-3)
}
