#!/usr/local/bin/python

## AUTHOR: Micheal Riedal ; 12/09/15 ; MODIFIED: Jessica Bartley ; 11/17/16
## This script extracts accuracy and response time information from the FCI E-prime text files
## Useage: call (after typing module load python), python FCI_Accuracy.py 
## The result is a text file with the same name as the input, but with FCIResponses added on

import csv, os, sys
from os import path
import numpy as np
import pandas as pd

subjects = np.genfromtxt('subject-list.txt', dtype=str)
sessions = ['session-0', 'session-1']
runs = ['1', '2', '3']

out_file_acc_rt = open("/home/data/nbc/physics-learning/data/behavioral-data/analyses/fci_accuracy_rt.txt", "a")
out_file_acc_rt.write("Subject\tSession\tMean FCI Accuracy\tMean Non-FCI Accuracy\tMean FCI RT\tMean Non-FCI RT\tMean FCI Screen1 RT\tMean FCI Screen2 RT\tMean FCI Screen3 RT\tMean Non-FCI Screen1 RT\tMean Non-FCI Screen2 RT\tMean Non-FCI Screen3 RT\n")

out_file_resp = open("/home/data/nbc/physics-learning/data/behavioral-data/analyses/fci_resp.txt", "a")
out_file_resp.write("Subject\tSession\n")

for sub in subjects:
	for sess in sessions:
		dirname = "/home/data/nbc/physics-learning/data/behavioral-data/rcsv/%s/%s" % (sub, sess)
		if os.path.isdir(dirname):
			fci_rt_all = []
			nonfci_rt_all = []
			fci_rt1_all = []
			nonfci_rt1_all = []
			fci_rt2_all = []
			nonfci_rt2_all = []
			fci_rt3_all = []
			nonfci_rt3_all = []
			fci_acc_all = []
			nonfci_acc_all = []
			fciresp_all = []
			nonfciresp_all = []
			fciquest_all = []
			nonfciquest_all = []
			for run in runs:
				if sub == '346' and sess == 'session-1':
					filename = "/home/data/nbc/physics-learning/data/behavioral-data/rcsv/%s/%s/FCI/FCI_%s_Goggles.csv" % (sub, sess, run)
				else:
					filename = "/home/data/nbc/physics-learning/data/behavioral-data/rcsv/%s/%s/FCI/FCI_%s.csv" % (sub, sess, run)
				if os.path.exists(filename):
					datafile = pd.read_csv(filename)
			
					fci = np.where(datafile['FCIQuestionBlock1.Cycle'] == 1)[0]
					nonfci = np.where(datafile['NonFCIQuestionBlock1.Cycle'] == 1)[0]
					
					fciresp = datafile['Slide3.RESP'][fci]
					fciresp = [i for i in fciresp]
					#nonfciresp = datafile['Slide3.RESP'][nonfci]
					#nonfciresp = [i for i in nonfciresp]
					
					fciquest = datafile['Question'][fci]
					fciquest = [i for i in fciquest]
					#nonfciquest = datafile['Question'][nonfci]
					#nonfciquest = [i for i in nonfciquest]
					
					fciresp_all.extend(fciresp)
					#nonfciresp_all.extend(nonfciresp)
					fciquest_all.extend(fciquest)
					#nonfciquest_all.extend(nonfciquest)
				
					rt1 = datafile['Slide1.RT']
					rt2 = datafile['Slide2.RT']
					rt3 = datafile['Slide3.RT']
					for i in np.where(rt1 == 0):
						rt1[i] = 15000
					for i in np.where(rt2 == 0):
						rt2[i] = 15000
					for i in np.where(rt3 == 0):
						rt3[i] = 15000

					fci_rt1 = rt1[fci]
					fci_rt2 = rt2[fci]
					fci_rt3 = rt3[fci]
			
					fci_rt = fci_rt1 + fci_rt2 + fci_rt3
					fci_rt = [i for i in fci_rt]
					fci_rt_all.extend(fci_rt)

					fci_rt1_all.extend(fci_rt1)
					fci_rt2_all.extend(fci_rt2)
					fci_rt3_all.extend(fci_rt3)
					
					nonfci_rt1 = rt1[nonfci]
					nonfci_rt2 = rt2[nonfci]
					nonfci_rt3 = rt3[nonfci]
			
					nonfci_rt = nonfci_rt1 + nonfci_rt2 + nonfci_rt3
					nonfci_rt = [i for i in nonfci_rt]
					nonfci_rt_all.extend(nonfci_rt)

					nonfci_rt1_all.extend(nonfci_rt1)
					nonfci_rt2_all.extend(nonfci_rt2)
					nonfci_rt3_all.extend(nonfci_rt3)

					fci_acc = datafile['Slide3.ACC'][fci]
					fci_acc = [i for i in fci_acc]
					fci_acc_all.append(fci_acc)
					nonfci_acc = datafile['Slide3.ACC'][nonfci]
					nonfci_acc = [i for i in nonfci_acc]
					nonfci_acc_all.append(nonfci_acc)

			#fci_quest_resp[:,1 = [fciquest_all, fciresp_all]
			fci_quest_resp = np.zeros([len(fciquest_all), 2])
			fci_quest_resp[:,0] = fciquest_all
			fci_quest_resp[:,1] = fciresp_all
			#nonfci_quest_resp = np.append(nonfciquest_all, nonfciresp_all, axis = 1)
			fci_quest_resp = fci_quest_resp[np.argsort(fci_quest_resp[:,0])]
			#nonfci_quest_resp = nonfci_quest_resp[np.argsort(nonfci_quest_resp[:,0])]
			fci_resp = np.transpose(fci_quest_resp[:,1])
			fci_resp[np.where(np.isnan(fci_resp))] = 0
			#nonfci_resp = np.transpose(nonfci_quest_resp[:,1])
			 
			writeline_acc_rt = "%s\t%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f" % (sub, sess, np.mean(fci_acc_all), np.mean(nonfci_acc_all), np.mean(fci_rt_all), np.mean(nonfci_rt_all), np.mean(fci_rt1_all), np.mean(fci_rt2_all), np.mean(fci_rt3_all), np.mean(nonfci_rt1_all), np.mean(nonfci_rt2_all), np.mean(nonfci_rt3_all))
			out_file_acc_rt.write(writeline_acc_rt + "\n")
			
			out_file_resp.write("%s\t%s\t" % (sub, sess))
			for i in fci_resp:
				out_file_resp.write(str(i.astype(int)) + "\t")
			out_file_resp.write("\n")
