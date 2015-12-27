
import os


for filename in os.listdir(os.getcwd()):
	print "Looking at ", filename
	if len(filename) < 7:
		code = filename[0:2]
		os.rename(filename, code + "@2x" + ".png")