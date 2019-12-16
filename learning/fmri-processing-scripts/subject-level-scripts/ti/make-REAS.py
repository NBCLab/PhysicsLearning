#!/usr/local/bin/python

# This is a macro for creating time files for the REAS runs

import csv, os, sys
from os import path
import numpy as np

filename = sys.argv[1];
outputfilename = sys.argv[2];
newfilename = filename.split('/')
fileuse = newfilename[-1]
fileinterest = fileuse.split('-')

datafile = np.genfromtxt(filename, names=True, delimiter=',', dtype=None)
scannerstart = np.array(datafile['Fixation10secWarmUp1OnsetTime'], dtype=float) #scannerstart
questionrt =  np.array(datafile['C1RT'], dtype=float) #reaction time
questionrtend = np.array(datafile['C1RTTime'], dtype=float) #end of screen
contrast = np.array(datafile['ContrastValue'], dtype=str)
didreact = [i for i,v in enumerate(questionrt) if v > 0]

newquestionrt = questionrt[didreact]
newquestionrtend = questionrtend[didreact]
newcontrast = contrast[didreact]

reaslocs = [i for i,v in enumerate(newcontrast) if v == "reasoning"]
baselocs = [i for i,v in enumerate(newcontrast) if v == "baseline"]


questiondurreas = newquestionrt[reaslocs]/2000
questionstartreas = (newquestionrtend[reaslocs]-newquestionrt[reaslocs]/2-(scannerstart[0]+10000))/1000
questiondurbase = newquestionrt[baselocs]/2000
questionstartbase = (newquestionrtend[baselocs]-newquestionrt[baselocs]/2-(scannerstart[0]+10000))/1000

reasfile = open(outputfilename + "-Reasoning.txt", "w")
basefile = open(outputfilename + "-Baseline.txt", "w")

for a in range(0,len(questionstartreas)-1):
    reasfile.write(str(questionstartreas[a]) + "\t" + str(questiondurreas[a]) + "\t" + str(1) + "\n")

for a in range(0,len(questionstartbase)-1):
    basefile.write(str(questionstartbase[a]) + "\t" + str(questiondurbase[a]) + "\t" + str(1) + "\n")
