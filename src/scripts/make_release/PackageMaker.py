import os
from regsub import gsub

# Makes a package for release.
class PackageMaker:
	# work_directory: temporary work directory for package file creation
	# package_directory: directory where packages are to be placed
	def __init__(self, work_directory, package_directory):
		self.work_directory = work_directory
		self.package_directory = package_directory

	def execute(self, package, file_tuples):
		if len(file_tuples) == 0:
			print '<Empty file list for package ' + package + \
				' - skipping ...>'
			return
		files = []
		# Create the list of files to be place in `package'.
		os.chdir(self.work_directory + '/..')
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
	# of self.work_directory.
	def make_file(self, tuple):
		dosstr = '[dos]'
		target = tuple[1]
		source = tuple[0]
		# The [dos] directive is not part of the file name - remove it.
		if target[len(target) - len(dosstr):] == dosstr:
			target = target[:-len(dosstr)]
		targetbase = os.path.basename(self.work_directory)
		if target == '.':
			result = targetbase + '/' + source
		elif os.path.isfile(targetbase + '/' + target):
			result = targetbase + '/' + target
		elif os.path.isdir(targetbase + '/' + target):
			result = targetbase + '/' + target + '/' + os.path.basename(source)
		else:
			raise "Error: " + target + \
				" is not a file or directory."
		return self.remove_double_slashes(result)

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

	def remove_double_slashes(self, path):
		result = gsub("///*", "/", path)
		return result
