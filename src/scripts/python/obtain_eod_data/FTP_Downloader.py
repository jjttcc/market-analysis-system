import sys
import os
from ftplib import FTP
from string import *

class FTP_Downloader:
	def __init__(self, conf_file_name):
		self.config_file_name = conf_file_name
		self.error = 0
		self.fatal = 0
		self.error_message = ""

	# files: list of each file to download
	# directories: list of the location of each member of `files'
	def run(self, files, dirs):
		self.error = 0
		self.fatal = 0
		try:
			# Expected format is simply: host\nuser\npassword
			file = open(self.config_file_name, 'r')
		except:
			print 'Failed to open file ' + self.config_file_name + \
				' (holds ' + 'ftp host/user/password information).'
			print sys.exc_info()[1]
			sys.exit(-1)
		self.host = file.readline()[:-1]
		self.user = file.readline()[:-1]
		self.password = file.readline()[:-1]
		file.close()
		try:
			file_name = None
			ftp = FTP(self.host, self.user, self.password)
			i = 0
			for file_name in files:
				file = open(file_name, 'w')
				ftp.cwd(dirs[i])
				print 'downloading '+file_name+' from '+dirs[i]
				ftp.retrbinary('RETR ' + file_name, file.write, 1024)
				i = i + 1
				file.close()
		except:
			self.error = 1
			# If the error is not due to the file not yet existing,
			# it's a fatal error.
			#if find(sys.exc_value, 'No such file or directory') == -1:
			#	self.fatal = 1
			self.error_message = 'ftp operation failed:\n' + sys.exc_info()[1]
			if file_name != None: os.unlink(file_name)
