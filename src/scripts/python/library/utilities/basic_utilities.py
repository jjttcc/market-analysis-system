# Basic python utilities
import sys

def abort(msg1 = None, msg2 = None):
	if msg1 != None:
		print msg1
	if msg2 != None:
		print msg2
	print "Exiting ..."
	sys.exit(-1)
