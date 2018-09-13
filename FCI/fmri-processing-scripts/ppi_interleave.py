# Author: Jessica Bartley
# Modified: 8/31/17

"""
This scrip creates FSL EV timing files for FCI PPI analyses.
The timing files screated are for the Physics - Control
contrast and for the Physics + Control contrast.
The Physics - Control EV will be entered into the PPI EV
"""

import itertools
import sys
import os

# set file names
control_file = sys.argv[1]
physics_file = sys.argv[2]
phys_control = sys.argv[3]
phys_plus_control = sys.argv[4]
pid = sys.argv[5]

# changes the weighting of 3rd column to -1
def invert(control_file):
	counter = 0
	c1 = []
	c2 = []
	c3 = []
	with open(control_file, 'r') as infile:
		with open('temp_'+pid+'.txt', 'w') as outfile:
			for line in infile:
				line = line.split()
				c1.append(float(line[0]))
				c2.append(float(line[1]))
				c3.append(float(line[2]))
				new_line = '{0}\t{1}\t{2}\n'.format(c1[counter], c2[counter], -1*c3[counter])
				counter = counter + 1
				outfile.write(new_line)
		outfile.close
	infile.close

# creates interleaved timing file
def interleave(infile1,infile2,outfile):
	files = [infile1, infile2]
	file_handler = []
	for f in files:
			file_handler.append(open(f))
	with open(outfile,'w') as of:
		for lines in itertools.izip(*file_handler):
			newf = ''.join(lines)
			of.write(newf)
	of.close

invert(control_file)
interleave(physics_file,'temp_'+pid+'.txt', phys_control)
interleave(physics_file,control_file,phys_plus_control)
os.remove('temp_'+pid+'.txt')
