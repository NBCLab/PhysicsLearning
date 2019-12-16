# Perform Class x Gender x Time ANOVA of behavioral measures with R for FCI
# Author: Taylor Salo and Jessica Bartley

# Import libraries
library('nlme')
library('multcomp')
library('tidyr')
library('RColorBrewer')
library('ggplot2')
library('EMAtools')

rm(list=ls())

# Location of data: FCI accuracy and RT
f = '/Users/jessicabartley/Documents/JessicaBartley/Documents/FIU/Research/Writing/PrePostFCIpaper/scripts/fci_accuracy_rtonly_gender_class_matched.txt'

# Read in data
data_wide = read.csv(file = f, sep = '\t')

# Convert to tall format
myData <- gather(data_wide, condition, measurement, 
                 Mean.FCI.Accuracy:Mean.Control.RT, factor_key=TRUE)

# Set columns as factors
myData <- within(myData, {
  subject <- factor(Subject)
  measure_type <- factor(condition)
  group <- factor(Group)
  gender <- factor(Gender)
  class <- factor(Class)
})

# Remove control and RT measures from main df (only interested in accuracy of stimulus condition)
myData<-myData[!(myData$condition=="Mean.Control.Accuracy"),]
myData<-myData[!(myData$condition=="Mean.Control.RT"),]
myData<-myData[!(myData$condition=="Mean.FCI.RT"),]

# Sort by subject (unnecessary)
myData <- myData[order(myData$subject), ]
head(myData)

# Get mean across observations for each combo
myData.mean <- aggregate(myData$measurement,
                         by=list(myData$subject,
                                 myData$Session,
                                 myData$measure_type,
                                 myData$group,
                                 myData$gender,
                                 myData$class),
                         FUN='mean')
colnames(myData.mean) <- c("subject", "session", "measure_type", "group", "gender", "class", "measure_value")
myData.mean <- myData.mean[order(myData.mean$subject), ]
head(myData.mean)

# Code drawn from https://stats.stackexchange.com/a/13816
# and https://stats.stackexchange.com/a/23014
# and https://stats.stackexchange.com/a/10909
# also referenced https://www.r-bloggers.com/two-way-anova-with-repeated-measures/ and https://m-clark.github.io/docs/mixedModels/anovamixed.html#more-mixed-model-repeated-measures-anova-equivalence
nMeasureTypes = length(unique(myData.mean$measure_type))
alpha = 0.05 / nMeasureTypes

count =0
for(i in unique(myData.mean$measure_type)){
  session_e = 0
  gender_e = 0
  class_e = 0
  print('-----------------------------------------------------------------------')
  print(i)
  redData = myData.mean[myData.mean$measure_type==i,]
  write.csv(redData, file = "3way_repeated_measurse_anova_fci_data.csv")
  # Given that only two timepoints are measured, let's treat session like a fixed effect
  model = lme(measure_value ~ class*gender*session, random=~1|subject, data=redData)
  modelAnova = anova(model)
  print(modelAnova)
  print(lme.dscore(model, redData, 'nlme'))
  p = modelAnova['class:gender:session', 'p-value']
  if(p < alpha){
    print('Three-way interaction is significant.')
    print('Interpret two-way interactions with care.')
    print('Focus on interpreting *simple* two-way interactions.')
    # see vingette on interpreting interactions here:
    # https://cran.r-project.org/web/packages/emmeans/vignettes/interactions.html
    # plot the three-way interaction to visualize
    with(redData, {interaction.plot(session, group, measure_value,
                                    pch = 19, 
                                    fixed=TRUE, 
                                    type="o",#use type="o" for points, "l" for line
                                    col=brewer.pal(n = 8, name = "Dark2"),
                                    lty=7,
                                    ylab=if(count < 2){'Mean Fraction Correct'}else('Mean RT (ms)'),
                                    xlab='Time',
                                    ylim = if(count < 0){range(0:1)}else(range(0:25000)),
                                    trace.label='Group',
                                    main=if(
                                      sub(".*?Mean.(.*?)*", "\\1", i[1])=="Control.Accuracy"){"Control Accuracy"}else if(
                                      sub(".*?Mean.(.*?)*", "\\1", i[1])=="FCI.Accuracy"){"FCI Accuracy"}else if(
                                      sub(".*?Mean.(.*?)*", "\\1", i[1])=="Control.RT"){"Control Response Time"}else if(
                                      sub(".*?Mean.(.*?)*", "\\1", i[1])=="FCI.RT"){"FCI Response Time"}else(""))})
    print(pairs(emmeans(model, ~ class*gender*session)))
  }
  else{
    print('--Three-way interaction is not significant. Running two-way interactions.--')
    class_sig = FALSE
    gender_sig = FALSE
    session_sig = FALSE
    tw_sig = FALSE
    p = modelAnova['class:gender', 'p-value']
    if(p < alpha){
      print('Interaction between class and gender is significant.')
      print('Focus on interpreting *simple* main effects of class and gender.')
      # plot the two-way interaction to visualize
      with(redData, {interaction.plot(class, gender, measure_value,
                                      pch = 19, 
                                      fixed=TRUE, 
                                      type="o",#use type="o" for points, "l" for line
                                      col=brewer.pal(n = 8, name = "Dark2"),
                                      lty=7,
                                      ylab=if(count < 2){'Mean Fraction Correct'}else('Mean RT (ms)'),
                                      xlab='Class',
                                      ylim = if(count < 2){range(0:1)}else(range(0:25000)),
                                      trace.label='Gender',
                                      main=if(
                                        sub(".*?Mean.(.*?)*", "\\1", i[1])=="Control.Accuracy"){"Control Accuracy"}else if(
                                        sub(".*?Mean.(.*?)*", "\\1", i[1])=="FCI.Accuracy"){"FCI Accuracy"}else if(
                                        sub(".*?Mean.(.*?)*", "\\1", i[1])=="Control.RT"){"Control Response Time"}else if(
                                        sub(".*?Mean.(.*?)*", "\\1", i[1])=="FCI.RT"){"FCI Response Time"}else(""))})
      print(pairs(emmeans(model, ~ class*gender)))
      class_sig = TRUE
      gender_sig = TRUE
      tw_sig = TRUE
    }
    p = modelAnova['class:session', 'p-value']
    if(p < alpha){
      print('Interaction between class and session is significant.')
      print('Focus on interpreting *simple* main effects of class and session')
      # plot the two-way interaction to visualize
      with(redData, {interaction.plot(session, class, measure_value,
                                      pch = 19, 
                                      fixed=TRUE, 
                                      type="o",#use type="o" for points, "l" for line
                                      col=brewer.pal(n = 8, name = "Dark2"),
                                      lty=7,
                                      ylab=if(count < 2){'Mean Fraction Correct'}else('Mean RT (ms)'),
                                      xlab='Time',
                                      ylim = if(count < 2){range(0:1)}else(range(0:25000)),
                                      trace.label='Class',
                                      main=if(
                                        sub(".*?Mean.(.*?)*", "\\1", i[1])=="Control.Accuracy"){"Control Accuracy"}else if(
                                        sub(".*?Mean.(.*?)*", "\\1", i[1])=="FCI.Accuracy"){"FCI Accuracy"}else if(
                                        sub(".*?Mean.(.*?)*", "\\1", i[1])=="Control.RT"){"Control Response Time"}else if(
                                        sub(".*?Mean.(.*?)*", "\\1", i[1])=="FCI.RT"){"FCI Response Time"}else(""))})
      print(pairs(emmeans(model, ~ class*session)))
      class_sig = TRUE
      session_sig = TRUE
      tw_sig = TRUE
    }
    p = modelAnova['gender:session', 'p-value']
    if(p < alpha){
      print('Interaction between gender and session is significant.')
      print('Focus on interpreting *simple* main effects of gender and session')
      # plot the two-way interaction to visualize
      with(redData, {interaction.plot(session, gender, measure_value,
                                      pch = 19, 
                                      fixed=TRUE, 
                                      type="o",#use type="o" for points, "l" for line
                                      col=brewer.pal(n = 8, name = "Dark2"),
                                      lty=7,
                                      ylab=if(count < 2){'Mean Fraction Correct'}else('Mean RT (ms)'),
                                      xlab='Time',
                                      ylim = if(count < 2){range(0:1)}else(range(0:25000)),
                                      trace.label='Gender',
                                      main=if(
                                        sub(".*?Mean.(.*?)*", "\\1", i[1])=="Control.Accuracy"){"Control Accuracy"}else if(
                                        sub(".*?Mean.(.*?)*", "\\1", i[1])=="FCI.Accuracy"){"FCI Accuracy"}else if(
                                        sub(".*?Mean.(.*?)*", "\\1", i[1])=="Control.RT"){"Control Response Time"}else if(
                                        sub(".*?Mean.(.*?)*", "\\1", i[1])=="FCI.RT"){"FCI Response Time"}else(""))})
      print(pairs(emmeans(model, ~ gender*session)))
      gender_sig = TRUE
      session_sig = TRUE
      tw_sig = TRUE
    }
    if(tw_sig == FALSE){
      print('No significant two-way interactions.')
      print('--Running main effects.--')
    }
    if(class_sig == FALSE){
      p = modelAnova['class', 'p-value']
      if(p < alpha){
        print('Main effect of class is significant.')
        print(summary(glht(model, linfct=mcp(class="Tukey")),
                      test=adjusted(type="bonferroni")))
      } else(class_e=1)
    }
    if(gender_sig == FALSE){
      p = modelAnova['gender', 'p-value']
      if(p < alpha){
        print('Main effect of gender is significant.')
        print(summary(glht(model, linfct=mcp(gender="Tukey")),
                      test=adjusted(type="bonferroni")))
      } else(gender_e=1)
    }
    if(session_sig == FALSE){
      p = modelAnova['session', 'p-value']
      if(p < alpha){
        print('Main effect of session is significant.')
        print(summary(glht(model, linfct=mcp(session="Tukey")),
                      test=adjusted(type="bonferroni")))
      } else(session_e=1)
    }
    if(session_e == 1 && gender_e == 1 && class_e == 1){
      print("No significant main effects")}
  }
  # plot the three-way interaction to visualize session differences, as a check to see if these ANOVAs are working ok
  with(redData, {interaction.plot(session, group, measure_value,
                                  pch = 19, 
                                  fixed=TRUE, 
                                  type="o",#use type="o" for points, "l" for line
                                  col=brewer.pal(n = 8, name = "Dark2"),
                                  lty=7,
                                  ylab=if(count < 2){'Mean Fraction Correct'}else('Mean RT (ms)'),
                                  xlab='Time',
                                  ylim = if(count < 2){range(0:1)}else(range(0:25000)),
                                  trace.label='Group',
                                  main=if(
                                    sub(".*?Mean.(.*?)*", "\\1", i[1])=="Control.Accuracy"){"Control Accuracy"}else if(
                                    sub(".*?Mean.(.*?)*", "\\1", i[1])=="FCI.Accuracy"){"FCI Accuracy"}else if(
                                    sub(".*?Mean.(.*?)*", "\\1", i[1])=="Control.RT"){"Control Response Time"}else if(
                                    sub(".*?Mean.(.*?)*", "\\1", i[1])=="FCI.RT"){"FCI Response Time"}else(""))})
  # plot the three-way interaction to visualize gender across time, as a check to see if these ANOVAs are working ok
  with(redData, {interaction.plot(session, gender, measure_value,
                                  pch = 19, 
                                  fixed=TRUE, 
                                  type="o",#use type="o" for points, "l" for line
                                  col=brewer.pal(n = 8, name = "Dark2"),
                                  lty=7,
                                  ylab=if(count < 2){'Mean Fraction Correct'}else('Mean RT (ms)'),
                                  xlab='Time',
                                  ylim = if(count < 2){range(0:1)}else(range(0:25000)),
                                  trace.label='Group',
                                  main=if(
                                    sub(".*?Mean.(.*?)*", "\\1", i[1])=="Control.Accuracy"){"Control Accuracy"}else if(
                                    sub(".*?Mean.(.*?)*", "\\1", i[1])=="FCI.Accuracy"){"FCI Accuracy"}else if(
                                    sub(".*?Mean.(.*?)*", "\\1", i[1])=="Control.RT"){"Control Response Time"}else if(
                                    sub(".*?Mean.(.*?)*", "\\1", i[1])=="FCI.RT"){"FCI Response Time"}else(""))})
  count=count+1
}


# Plot measures across gender and class groups
f_acc_pre = '/Users/jessicabartley/Documents/JessicaBartley/Documents/FIU/Research/Writing/PrePostFCIpaper/scripts/fci_accuracy_gender_class_matched_pre.txt'
f_rt_pre = '/Users/jessicabartley/Documents/JessicaBartley/Documents/FIU/Research/Writing/PrePostFCIpaper/scripts/fci_rt_gender_class_matched_pre.txt'
f_acc_post = '/Users/jessicabartley/Documents/JessicaBartley/Documents/FIU/Research/Writing/PrePostFCIpaper/scripts/fci_accuracy_gender_class_matched_post.txt'
f_rt_post = '/Users/jessicabartley/Documents/JessicaBartley/Documents/FIU/Research/Writing/PrePostFCIpaper/scripts/fci_rt_gender_class_matched_post.txt'

data_wide_acc_pre = read.csv(file = f_acc_pre, sep = '\t')
data_wide_rt_pre = read.csv(file = f_rt_pre, sep = '\t')
data_wide_acc_post = read.csv(file = f_acc_post, sep = '\t')
data_wide_rt_post = read.csv(file = f_rt_post, sep = '\t')

myData_acc_pre <- gather(data_wide_acc_pre, condition, measurement, Mean.FCI.Accuracy:Mean.Control.Accuracy, factor_key=TRUE)
myData_rt_pre <- gather(data_wide_rt_pre, condition, measurement, Mean.FCI.RT:Mean.Control.RT, factor_key=TRUE)
myData_acc_post <- gather(data_wide_acc_post, condition, measurement, Mean.FCI.Accuracy:Mean.Control.Accuracy, factor_key=TRUE)
myData_rt_post <- gather(data_wide_rt_post, condition, measurement, Mean.FCI.RT:Mean.Control.RT, factor_key=TRUE)
datanames = list('Pre Accuracy', 'Pre Response Time', 'Post Accuracy', 'Post Response Time')
data = list(myData_acc_pre, myData_rt_pre, myData_acc_post, myData_rt_post)

count=0
for(dataset in data){
  myData_plot <- dataset
  # Set columns as factors
  myData_plot <- within(myData_plot, {
    subject <- factor(Subject)
    measure_type <- factor(condition)
    group <- factor(Group)
    gender <- factor(Gender)
  })
  myData_plot <- myData_plot[order(myData_plot$subject), ]
  myData_plot.mean <- aggregate(myData_plot$measurement,
                           by=list(myData_plot$subject,
                                   myData_plot$Session,
                                   myData_plot$measure_type,
                                   myData_plot$group,
                                   myData_plot$gender),
                           FUN='mean')
  colnames(myData_plot.mean) <- c("subject", "session", "measure_type", "group", "gender", "measure_value")
  myData_plot.mean <- myData_plot.mean[order(myData_plot.mean$subject), ]
  with(myData_plot.mean, {interaction.plot(group, measure_type, measure_value,
                                      pch = 19, fixed=TRUE, type="o",#use type="o" for points, "l" for line
                                      col=brewer.pal(n = 8, name = "Dark2"),
                                      lty=7,
                                      ylab=if((count %% 2) == 0){'Mean Fraction Correct'}else('Mean RT (ms)'),
                                      xlab='Groups',
                                      ylim = if((count %% 2) == 0){range(0:1)}else(range(0:25000)),
                                      trace.label='Measures', 
                                      main=if(count==0){
                                        'Pre Accuracy Plot'}else if(count==1){
                                        'Pre Reaction Time Plot'}else if(count==2){
                                        'Post Accuracy Plot'}else{
                                        'Post Reaction Time Plot'})})
  with(myData_plot.mean, {interaction.plot(gender, measure_type, measure_value,
                                           pch = 19, fixed=TRUE, type="o",#use type="o" for points, "l" for line
                                           col=brewer.pal(n = 8, name = "Dark2"),
                                           lty=7,
                                           ylab=if((count %% 2) == 0){'Mean Fraction Correct'}else('Mean RT (ms)'),
                                           xlab='Gender',
                                           ylim = if((count %% 2) == 0){range(0:1)}else(range(0:25000)),
                                           trace.label='Measures', 
                                           main=if(count==0){
                                              'Pre Accuracy Plot'}else if(count==1){
                                              'Pre Reaction Time Plot'}else if(count==2){
                                              'Post Accuracy Plot'}else{
                                              'Post Reaction Time Plot'})})
  count=count+1
}
