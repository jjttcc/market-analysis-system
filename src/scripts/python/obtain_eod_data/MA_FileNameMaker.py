class MA_FileNameMaker:
	def mime_data_file_name(self, date):
		return "eod." + date
	def mime_data_dir_name(self):
		return "store"
