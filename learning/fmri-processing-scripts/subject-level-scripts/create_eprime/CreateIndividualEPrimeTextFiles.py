#!/usr/local/bin/python

# This is a macro for creating time files for the FCI (? for REAS) runs (to be used in FSL FCI analyses)
# AUTHOR: Michael Riedel
# Useage: need to check this - I (JB) thinks its probably somthing like python CreateIndividualEPrimeTextFiles.py MERGED_EDAT_FILE_WITH_ALL_INFORMATION 
# ... but I need to check on that

import os
import sys
import numpy as np


def main(filename):
    """
    Split merged exported edat-text files by subject and experiment. Save split
    arrays as tab-delimited text files.
    """
    out_dir = os.path.dirname(filename)
    datafile = np.genfromtxt(filename, names=True, delimiter='\t', dtype=None)
    
    subject_col = datafile["Subject"]
    subjects = np.unique(subject_col)
    
    for subject in subjects:
        subject_rows = np.where(subject_col==subject)[0]
        subject_data = datafile[subject_rows]
        exp_col = subject_data["ExperimentName"]
        experiments = np.unique(exp_col)
        for exp in experiments:
            exp_rows = np.where(exp_col==exp)[0]
            exp_data = subject_data[exp_rows]
            sess_col = np.array(exp_data["Session"], dtype=str)
            session = np.unique(sess_col)[0]
	    session = str(int(session) - 1)
            
            column_names = np.array(exp_data.dtype.names, dtype=str)
            header_string = "\t".join(column_names)
            out_list = [str(subject), session, str(exp), "eprime.txt"]
            out_file = os.path.join(out_dir, "-".join(out_list))
            with open(out_file, "w") as fo:
                np.savetxt(fo, exp_data, delimiter="\t", newline="\n",
                           fmt="%s", header=header_string, comments="")


if __name__ == "__main__":
    filename = sys.argv[1]
    main(filename)
