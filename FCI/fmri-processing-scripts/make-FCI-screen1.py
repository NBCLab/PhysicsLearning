#!/usr/local/bin/python

# This is a macro for creating time files for the FCI runs for screen 1 only

import csv, os, sys
from os import path
import numpy as np

filename = sys.argv[1];
outputfilename = sys.argv[2];
newfilename = filename.split('/')
fileuse = newfilename[-1]
fileinterest = fileuse.split('-')

datafile = np.genfromtxt(filename, names=True, delimiter=',', dtype=None)
scannerstart = np.array(datafile['Fixation4secAfterWarmUpOnsetTime'], dtype=float) #scannerstart
questionstart =  np.array(datafile['Slide1OnsetTime'], dtype=float) #questionstart
questionend =  np.array(datafile['Slide2OnsetTime'], dtype=float) #questionend
fciblock = np.array(datafile['FCIQuestionBlock1Cycle'])
nonfciblock = np.array(datafile['NonFCIQuestionBlock1Cycle'])

isfci = np.where(fciblock=='1')
isnonfci = np.where(nonfciblock=='1')

fcidur = (questionend[isfci]-questionstart[isfci])/1000
questionstartfci = (questionstart[isfci]-scannerstart[0])/1000
itsfci = fciblock[isfci]
nonfcidur = (questionend[isnonfci]-questionstart[isnonfci])/1000
questionstartnonfci = (questionstart[isnonfci]-scannerstart[0])/1000
itsnotfci = nonfciblock[isnonfci]

physfile = open(outputfilename + "-Screen1-Physics.txt", "w")
nonphysfile = open(outputfilename + "-Screen1-NonPhysics.txt", "w")

for a in range(0,3):
    physfile.write(str(questionstartfci[a]) + "\t" + str(fcidur[a]) + "\t" + str(itsfci[a]) + "\n")
    nonphysfile.write(str(questionstartnonfci[a]) + "\t" + str(nonfcidur[a]) + "\t" + str(itsnotfci[a]) + "\n")
