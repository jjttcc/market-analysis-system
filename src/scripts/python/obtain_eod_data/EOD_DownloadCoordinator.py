# Coordinates downloading end-of-day data.

import os
import sys
from time import sleep

class EOD_DownloadCoordinator:

	def __init__(self, date, factory):
		self.date = date
		self.env = factory.environment()
		self.connection = factory.connection()
		self.downloader = factory.downloader()
		self.file_name_maker = factory.file_name_maker()
		self.maxtries = 40
		self.tries = 0

	def run(self):
		while self.tries < self.maxtries:
			os.chdir(self.env.eod_dir)
			self.connection.connect()
			mime_file_name = self.file_name_maker.mime_data_file_name(self.date)
			mime_file_dir = self.file_name_maker.mime_data_dir_name()
			self.downloader.run([mime_file_name], [mime_file_dir])
			self.connection.disconnect()
			if self.downloader.error:
				print "Error downloading file " + mime_file_name + ": " + \
						self.downloader.error_message
				if self.downloader.fatal:
					print "Fatal error - exiting ..."
					sys.exit(-1)
			else:
				break
			self.tries = self.tries + 1
			print "Download attemp %d  failed, sleeping ..." % self.tries
			sleep(240)
