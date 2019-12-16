import os
import sys
from glob import glob
sys.path.append("/home/data/nbc/tools/convert-eprime/")
import convert_eprime as ce

# Constants
data_dir = "/home/data/nbc/physics-learning/data/behavioral-data/"
raw_dir = os.path.join(data_dir, "raw/")
out_dir = os.path.join(data_dir, "rcsv/")

tasks = ["FCI"]#, "REAS", "RETR"]
timepoints = ["Pre", "Post"]

for task in tasks:
    task_dirs = glob(os.path.join(raw_dir, task + "*"))
    for task_dir in task_dirs:
        for timepoint in timepoints:
            timepoint_dir = os.path.join(task_dir, timepoint)
            subject_files = glob(os.path.join(timepoint_dir, task + "*.txt"))
            for subject_file in subject_files:
                pre, _ = os.path.splitext(subject_file)
                filename = os.path.basename(pre)
                edat_search = os.path.join(timepoint_dir, filename+".edat*")
                if not glob(edat_search):
                    print("\n{0}".format(edat_search))
                    print("No EDAT found.\n")
                    continue
                else:
                    edat_file = glob(edat_search)[0]

                info = filename.split("-")
                run = info[0]
                subject = info[1]
                session = "session-{0}".format(int(info[2]) - 1)  # 1 = session-0, 2 = session-1, etc.

                subj_dir = os.path.join(out_dir, subject)
                if not os.path.exists(subj_dir):
                    os.mkdir(subj_dir)

                sess_dir = os.path.join(subj_dir, session)
                if not os.path.exists(sess_dir):
                    os.mkdir(sess_dir)

                task_dir = os.path.join(sess_dir, task)
                if not os.path.exists(task_dir):
                    os.mkdir(task_dir)

                out_file = os.path.join(task_dir, "{0}.csv".format(run))
                #print out_file
                ce.text_to_rcsv(subject_file, edat_file, out_file, "PHYS_"+task)