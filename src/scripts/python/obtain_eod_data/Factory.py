from FTP_Downloader import FTP_Downloader
from ISP_Connection import ISP_Connection
from MA_FileNameMaker import MA_FileNameMaker
from MA_Environment import MA_Environment

class Factory:
	def environment(self):
		return MA_Environment()

	def connection(self):
		return ISP_Connection()

	def downloader(self):
		return FTP_Downloader('ftp_config')

	def file_name_maker(self):
		return MA_FileNameMaker()
