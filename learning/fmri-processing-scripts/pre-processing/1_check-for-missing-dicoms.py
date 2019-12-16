import os
from glob import glob

#
# This program checks all participant DICOM files to make sure no individual dicom images are missing
# Usage: run from the directory containing all PID folders
# Authors: Jessica Bartley and Rafael Badui
# Edits: Taylor Salo on 9/26/16
#


def checkpartic(partic, dir_='.'):
	"""
	Returns list of missing runs or sessions.
	"""
	check_list=['FCI_1', 'FCI_2', 'FCI_3',
			    'REAS_1', 'REAS_2',
			    'RETR_1', 'RETR_2',
			    'Resting_State', 'Structural']
	error_list = []
	datestr = '[0-9]' * 8
	date_dirs = glob(os.path.join(dir_, partic, datestr))
	dates = sorted([os.path.basename(date_dir) for date_dir in date_dirs])
	for session in dates:
		runs = os.listdir(os.path.join(dir_, partic, session))
		runs = sorted([run for run in runs if os.path.isdir(os.path.join(partic, session, run))])
		for item in check_list:
			found = False
			for run in runs:
				if item in run:
					found = True

			if not found:
				error_list.append('{0} not found for {1} session {2}'.format(item, partic, session))

	if len(error_list) > 0:
		with open(os.path.join(dir_, 'summary', '{0}.txt'.format(partic)), 'w') as fo:
			for item in error_list:
				fo.write(item+'\n')


def checkdicoms(partic, dir_='.'):
	"""
	Returns list of missing or odd number of dicoms
	"""
	subj_dir = os.path.abspath(os.path.join(dir_, partic))
	datestr = '[0-9]' * 8
	date_dirs = glob(os.path.join(dir_, partic, datestr))
	dates = sorted([os.path.basename(date_dir) for date_dir in date_dirs])
	for session in dates:
		sess_dir = os.path.join(subj_dir, session)
		runs = os.listdir(partic+'/'+session)
		runs = sorted([run for run in runs if os.path.isdir(os.path.join(partic, session, run))])
		for run in runs:
			run_dir = os.path.join(sess_dir, run)
			n_dicoms = len(glob(os.path.join(run_dir, '*.dcm')))
			if 'FCI' in run:
				if partic.startswith('1') and session.startswith('201409'):
				 	if n_dicoms != 7014:
				 		with open('summary/{0}.txt'.format(partic), 'a+') as f:
							f.write("{0} session {1} run {2} has unexpected number of dicoms = {3}\n".format(partic,
																										     session,
																										     run,
																										     n_dicoms))
				elif n_dicoms!=7224:
					with open('summary/{0}.txt'.format(partic), 'a+') as f:
						f.write("{0} session {1} run {2} has unexpected number of dicoms = {3}\n".format(partic,
																										session,
																										run,
																										n_dicoms))

			if 'Resting_State' in run:
				if partic[0] == '1' and session[:6] == '201409':
				 	if n_dicoms != 15120:
						with open('summary/{0}.txt'.format(partic), 'a+') as f:
							f.write("{0} session {1} run {2} has unexpected number of dicoms = {3}\n".format(partic,
																											session,
																											run,
																											n_dicoms))

				elif n_dicoms!=15330:
					with open('summary/{0}.txt'.format(partic), 'a+') as f:
						f.write("{0} session {1} run {2} has unexpected number of dicoms = {3}\n".format(partic,
																										session,
																										run,
																										n_dicoms))

			if 'RETR' in run:
				if partic[0] == '1' and session[:6] == '201409':
				 	if n_dicoms != 7266:
						with open('summary/{0}.txt'.format(partic), 'a+') as f:
							f.write("{0} session {1} run {2} has unexpected number of dicoms = {3}\n".format(partic,
																											session,
																											run,
																											n_dicoms))

				elif n_dicoms!=7476:
					with open('summary/{0}.txt'.format(partic), 'a+') as f:
						f.write("{0} session {1} run {2} has unexpected number of dicoms = {3}\n".format(partic,
																										session,
																										run,
																										n_dicoms))					
		
			if 'REAS' in run:
				if partic[0] == '1' and session[:6] == '201409':
				 	if n_dicoms != 8820:
						with open('summary/{0}.txt'.format(partic), 'a+') as f:
							f.write("{0} session {1} run {2} has unexpected number of dicoms = {3}\n".format(partic,
																											session,
																											run,
																											n_dicoms))
				elif n_dicoms!=9030:
					with open('summary/{0}.txt'.format(partic), 'a+') as f:
						f.write("{0} session {1} run {2} has unexpected number of dicoms = {3}\n".format(partic,
																										session,
																										run,
																										n_dicoms))

			if 'Structural' in run:
				if n_dicoms!=186:
					with open('summary/{0}.txt'.format(partic), 'a+') as f:
						f.write("{0} session {1} run {2} has unexpected number of dicoms = {3}\n".format(partic,
																										session,
																										run,
																										n_dicoms))

def checkall(dir_):
	allpartic = os.listdir(dir_)
	allpartic = sorted([partic for partic in allpartic if partic.isdigit() or partic=='108B'])
	for partic in allpartic:
		checkpartic(partic, dir_)
		checkdicoms(partic, dir_)


if __name__ == '__main__':
	import sys
	if len(sys.argv) < 2:
		dir_ = os.path.abspath('.')
	else:
		dir_ = os.path.abspath(sys.argv[1])
	checkall(dir_)
