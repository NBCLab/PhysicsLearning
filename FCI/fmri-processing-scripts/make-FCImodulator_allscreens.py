#!/usr/local/bin/python
# This is a macro for creating EV files for the FCI runs with parametric modulators
# Useage: python make-FCImodulator.py [eprime file] [out_filename_base] [modulator file] [participantID] [session#]
# Author: Jessica Bartley

import csv, os, sys
from os import path
import numpy as np
print np.__version__

# inputs: [eprime file] [out_filename_base] [participantID] [session#]
filename = sys.argv[1];
outputfilename = sys.argv[2];
modulatorfilename = sys.argv[3];
pid = int(sys.argv[4]);
sessioncount = int(sys.argv[5])+1;
newfilename = filename.split('/')
fileuse = newfilename[-1]
fileinterest = fileuse.split('-')

### define dictionaries and declare array
# q difficulty (demeaned)
qdiffs = {2:"15.4", 3:"-1.5", 6:"-23.6", 7:"-16.4", 8:"-0.4", 12:"-15.2", 14:"10.5", 27:"-9.4", 29:"-0.8"} # % difficulty = [34.6, 51.5, 73.6, 66.4, 50.4, 65.2, 39.5, 59.4, 50.8]
# q index key. fci q: survey q
q_fci2survey = {2:1, 8:2, 6:3, 7:4, 3:5, 12:6, 14:7, 27:8, 29:9}
itsqnum_survey = []
isq_survey = []
q_reorder = []
q_neworder =[]

### retrieve columns of interest
## eprime file
datafile = np.genfromtxt(filename, names=True, delimiter=',', dtype=None)
scannerstart = np.array(datafile['Fixation4secAfterWarmUpOnsetTime'], dtype=float) #scannerstart
questionstart =  np.array(datafile['Slide1OnsetTime'], dtype=float) #questionstart
questionend =  np.array(datafile['Fixation2OnsetTime'], dtype=float) #questionend
fciblock = np.array(datafile['FCIQuestionBlock1Cycle'])
questionnum = np.array(datafile['Question']) # fci q number
questionresp = np.array(datafile['Slide3RESP']) # q response
questionacc = np.array(datafile['Slide3ACC']) # all accuracies, note: if no response recorded then acc coded as 0 by default
## modulator file
modulatorfile = np.genfromtxt(modulatorfilename, names=True, delimiter='\t', dtype=None) # contained demeaned data
participantid = np.array(modulatorfile['PID'], dtype=int)
participantsession = np.array(modulatorfile['Session']) # note: modulator file indexes "pre" as 1 and "post" as 2
questionnum_survey = np.array(modulatorfile['QuestionNum'], dtype=int)
questionreas = np.array(modulatorfile['UsedKnowledgeAndReas_scaled'], dtype=float)
questiongut = np.array(modulatorfile['GutFeeling_scaled'], dtype=float)

### identify loc of elements: var naming convention is isELEMENT
isfci = np.where(fciblock=='1')
ispid = np.where(participantid==pid)
issessioncount = np.where(participantsession==sessioncount)
ispidandsessioncout = np.intersect1d(np.array(ispid), np.array(issessioncount)) #vector of row locations for a specific pid and session

### deman accuracy array
questionacc_demeaned = questionacc*2-1
## replace instance of no response with with accuracy of 0
for i in range(0,6):
    if questionacc[i] == 0:
        if questionresp[i] == -1:
            questionacc_demeaned[i] = questionacc[i]

### values of interest: var naming convention is itsELEMENT
fcidur = (questionend[isfci]-questionstart[isfci])/1000 # q duration
questionstartfci = (questionstart[isfci]-scannerstart[0])/1000 # q start time
itsfci = fciblock[isfci]
itsacc = questionacc_demeaned[isfci] # demeaned q accuracy
itsqnum = questionnum[isfci] # q in-scanner presentation order

### retrieve temporally ordered q loc in modulator file
for a in range(0,3): itsqnum_survey.append(q_fci2survey[itsqnum[a]]) # q numbers in modulator file for the run
for a in range(0,3): isq_survey.append(np.where(questionnum_survey==itsqnum_survey[a]))#loc of all q's in modulator file for the run
isqandpidandsessioncount = np.intersect1d(np.array(isq_survey), np.array(ispidandsessioncout)) # q loc's in modulator file for the run (not in order of q presentation)
## reorder modulator file loc array to match q presentation order
q_fciorder = np.asarray([q_fci2survey[x] for x in itsqnum]) # q number in-scanner presentation order
for i in q_fciorder:
    q_reorder.append(isqandpidandsessioncount[np.where(questionnum_survey[isqandpidandsessioncount] == i)].tolist()) # q loc in modulator file in presentation order
q_reorder_mat = np.vstack(q_reorder)# dtype: list->array
for x in range(0,3): q_neworder.append(q_reorder_mat[x][0])#   q loc's in modulator file in presentation order
itsreas = questionreas[q_neworder] # demeaned "used reasoning and knowledge" values in presentation order
itsgut = questiongut[q_neworder] # demeaned "used gut feeling" valyes ordered in presentation order

#### make EV txt files
## reasoning strategy file
physReasfile = open(outputfilename + "-physStrategyReas-allscreens.txt", "w+")
for a in range(0,3):
    physReasfile.write(str(questionstartfci[a]) + "\t" + str(fcidur[a]) + "\t" + str(itsreas[a]) + "\n")
physReasfile.close()

## gutfeeling strategy file
physGutfile = open(outputfilename + "-physStrategyGutFeeling-allscreens.txt", "w+")
for a in range(0,3):
    physGutfile.write(str(questionstartfci[a]) + "\t" + str(fcidur[a]) + "\t" + str(itsgut[a]) + "\n")
physGutfile.close()

## difficulty file
physDifffile = open(outputfilename + "-physDiff-allscreens.txt", "w+")
for a in range(0,3):
    physDifffile.write(str(questionstartfci[a]) + "\t" + str(fcidur[a]) + "\t" + str(qdiffs[itsqnum[a]]) + "\n")#qdiffs[itsqnum[a]] is the vector of fci question order as indexed by the strategy survey
physDifffile.close()

## accuracy file
physaccfile = open(outputfilename + "-physAcc-allscreens.txt", "w+")
for a in range(0,3):
    physaccfile.write(str(questionstartfci[a]) + "\t" + str(fcidur[a]) + "\t" + str(itsacc[a]) + "\n")
physaccfile.close()





