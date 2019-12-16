#!/bin/bash -f
#### Takes raw fMRI data and unpacks it via the dicom_rename.pl scipt

cd /home/data/nbc/DICOM &&
#mkdir JBsorted
#module load afni &&
#echo "afni loaded"

#########################
####### CHANGE ME ####### 
#########################

#name of temp data folder in DICOM
tempDir=JBtemp

#change for session number
session=Session2

#change for subject ID

	#if only doing one participant
	#for i in 503; do

	#if processing multiple participants simultaneously
	for i in {629,627,621}; do

#########################
##### END CHANGE ME ##### 
#########################

		cp /data/nbc/DICOM/$tempDir/$i/$session/A.tar /data/nbc/DICOM &&
		cp /data/nbc/DICOM/$tempDir/$i/$session/B.tar /data/nbc/DICOM &&

		echo $i $session "STEP 1: A.tar and B.tar have been moved to DICOM directory" &&

		tar xfz A.tar &&
		tar xfz B.tar &&

# this step was needed when untar retained my directory path - no longer needed
#        mv /data/nbc/DICOM/$i/$session/A /data/nbc/DICOM
#        mv /data/nbc/DICOM/$i/$session/B /data/nbc/DICOM
#        mv /data/nbc/DICOM/$i/ /data/nbc/DICOM/JBsorted/$i

		echo $i $session "STEP 2: A and B folders for have been extracted" &&

		rm A.tar B.tar &&

		echo $i $session "STEP 3: A.tar and B.tar files have been removed from DICOM directory" &&

		echo $i $session "STEP 4: running dicom_rename on folder A" &&

		./dicom_rename_JB.pl A &&

		echo $i $session "STEP 5: Folder A sorted. Running dicom_rename on folder B now..."

		./dicom_rename_JB.pl B &&

		echo "*** FINISHED sorting Participant" $i $session "***" ;

done
