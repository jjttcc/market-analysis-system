import os

# Makes a package for release.
class PackageMaker:
	# target_directory: root directory where target files are placed
	# package_directory: directory where package is to be placed
	def __init__(self, target_directory, package_directory):
		self.target_directory = target_directory
		self.package_directory = package_directory

	def execute(self, package, file_tuples):
		if len(file_tuples) == 0:
			print '<Empty file list for package ' + package + \
				' - skipping ...>'
			return
		files = []
		# Create the list of files to be place in `package'.
		os.chdir(self.target_directory + '/..')
		for t in file_tuples:
			files.append(self.make_file(t))
		# cd to where the files to be packaged now reside.
		if not os.path.exists(self.package_directory):
			os.system('mkdir -p ' + self.package_directory)
		# Create and execute the packaging commands.
		file_list = self.file_list(files)
		tarcmd = 'tar cvfz ' + self.package_directory + '/' + package + \
			'.tar.gz' + ' ' + file_list
		zipcmd = 'zip -r ' + self.package_directory + '/' + package + \
			'.zip' + ' ' + file_list
		os.system(tarcmd)
		os.system(zipcmd)

	# Expects current directory to be the parent of the base directory
	# of self.target_directory.
	def make_file(self, tuple):
		target = tuple[1]
		source = tuple[0]
		targetbase = os.path.basename(self.target_directory)
		if target == '.':
			result = targetbase + '/' + source
		elif os.path.isfile(targetbase + '/' + target):
			result = targetbase + '/' + target
		elif os.path.isdir(targetbase + '/' + target):
			result = targetbase + '/' + target + '/' + os.path.basename(source)
		else:
			raise "Error: " + target + \
				" is not a file or directory."
		return result

	def file_list(self, files):
		if len(files) == 0:
			raise "Program error: file_list passed empy list."
		result = ''
		i = 0
		while i < len(files) - 1:
			result = result + files[i] + ' '
			i = i + 1
		result = result + files[i]
		return result
