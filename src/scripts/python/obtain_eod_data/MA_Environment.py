import os
import sys

class MA_Environment:
	def __init__(self):
		eod_var = 'EOD_DIRECTORY'
		if os.environ.has_key(eod_var):
			self.eod_dir = os.environ[eod_var]
		else:
			print 'environment variable ' + eod_var + ' was not set.'
			sys.exit(-1)
