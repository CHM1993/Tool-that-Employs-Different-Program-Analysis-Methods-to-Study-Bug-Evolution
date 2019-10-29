#!/usr/bin/env python -tt

import fnmatch
import os
import os.path
import sys
import json
import io
import pandas as pd
import plotly.plotly as py
import plotly.graph_objs as go
import matplotlib.pyplot as plt; plt.rcdefaults()
import numpy as np
import matplotlib.pyplot as plt
import csv


data3={ }
data3['Utils']={ }
data3['Utils']['Coreutils']={ }
prevcount=0
count=0
time =0
crashes=0
prevcrashes=0
flawfindererrors=0
prevflawfindererrors=0
comments=0
prevcomments=0
code=0
prevcode=0
lastpart2 = None
for dirName, subdirList, fileList in os.walk(sys.argv[1]):
#	print('Found directory: %s' % dirName)
	
	for d in os.walk(dirName):
		lastpart = os.path.basename(os.path.normpath(dirName))
		print(lastpart)
		if 'coreutils-' in lastpart:
			if (lastpart2 != lastpart):
#				print(lastpart)
				lastpart2=lastpart
				if (time > 0):
					data3['Utils']['Coreutils'][finalv]['Lines of C code'] = code
					data3['Utils']['Coreutils'][finalv]['Comments'] = comments
					data3['Utils']['Coreutils'][finalv]['Number of klee errors/crashes'] = count
					data3['Utils']['Coreutils'][finalv]['Number of afl errors/crashes'] = crashes
					data3['Utils']['Coreutils'][finalv]['Number of flawfinder error/crashes'] = flawfindererrors
				finalv = lastpart
				data3['Utils']['Coreutils'][lastpart2]={ }
				prevcount = count
				count=0
				time = 1
				prevcrashes = crashes
				crashes = 0
				prevflaw= flawfindererrors
				flawfindererrors=0
				prevcomments= comments
				comments=0
				prevcode = code
				code=0
		for fname in fileList:
			if fname.endswith(".err"):
				count = count +1

		for fname in fileList:
			if 'flawfinder' in fname:
				print(os.getcwd())
				dir_path = os.path.dirname(os.path.realpath(fname))
				fname2 = os.getcwd()+'/'+sys.argv[1]+'/'+fname[19:33]+'/'+'flawfinder/'+fname #
				with open(fname2, 'r+') as fd:
					for line in fd:
#					print(line)
						if "Hits@level" in line:
#							print(line)
							flawfindererrors = line[-2]  
#							print(flawfindererrors)
			if 'cloc' in fname:
				dir_path = os.path.dirname(os.path.realpath(fname))
				fname2 = os.getcwd()+'/'+sys.argv[1]+'/'+fname[5:19]+'/'+'cloc/'+fname
				print(fname)
				with open(fname2, 'r+') as fd:
					for line in fd:
						if "Language" in line:
#							print(line)
#							line.split()
							print(line)
							line=fd.next()
							print(line)
							line=fd.next()
							print(line)
							comments = line.split()[-2]
							print(comments)
							code = line.split()[-1]
							print(code)


		if 'crashes' in lastpart:
			for fname in fileList:
				crashes = crashes +1

data3['Utils']['Coreutils'][finalv]['Lines of C code'] = code
data3['Utils']['Coreutils'][finalv]['Comments'] = comments
data3['Utils']['Coreutils'][finalv]['Number of klee errors/crashes'] = count
data3['Utils']['Coreutils'][finalv]['Number of afl errors/crashes'] = crashes
data3['Utils']['Coreutils'][finalv]['Number of flawfinder error/crashes'] = flawfindererrors
print(count)
print 'JSON', json.dumps(data3)
with open('answer3.json','w') as f:
	json.dump(data3, f, indent=2, ensure_ascii=False)



df = pd.DataFrame(data3['Utils']['Coreutils'])
print(df)
df.to_csv('file2.csv') 
#df=pd.read_csv('file1.csv',delimiter=',',header=[0,1,2], )
index = ['snail', 'pig', 'elephant','rabbit', 'giraffe', 'coyote', 'horse']
df=pd.read_csv('file2.csv',delimiter=',', header =[0, 1, 2], index_col=[0]) #me tin  skiprows=[4, 5] kanoume ena ena

df.plot.bar()
bars = ('AFL', 'FLAWFINDER', 'KLEE')
y_pos = np.arange(len(bars))
#plt.bar(y_pos,)
plt.title('Coreutils Versions Errors')
plt.xlabel('Tools')
plt.ylabel('Errors/crashes')
plt.xticks(y_pos, bars)

#Flawfinder
df=pd.read_csv('file2.csv',delimiter=',', header =[0, 1, 2], skiprows=[3,5], index_col=[0])
df.plot.bar()
bars = ('FLAWFINDER')
#plt.bar(y_pos,)
plt.title('Coreutils Flawfinder Errors')
plt.xlabel('Flawfinder')
plt.ylabel('Number of errors')
 
plt.show()

#klee
df=pd.read_csv('file2.csv',delimiter=',', header =[0, 1, 2], skiprows=[3,4], index_col=[0])
df.plot.bar()
bars = ('Klee')
#plt.bar(y_pos,)
plt.title('Coreutils Klee Errors')
plt.xlabel('Klee')
plt.ylabel('Number of errors')
 
plt.show()

#AFL
df=pd.read_csv('file2.csv',delimiter=',', header =[0, 1, 2], skiprows=[4,5], index_col=[0])
df.plot.bar()
bars = ('AFL')
#plt.bar(y_pos,)
plt.title('Coreutils AFL Errors')
plt.xlabel('AFL')
plt.ylabel('Number of errors')
 
plt.show()
 
plt.show()


# to run -- python ./core_errors.py Utils/Coreutils/
