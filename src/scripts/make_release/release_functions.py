# Utility functions for making releases

import os
from sys import *
from __builtin__ import open
from string import *
from PackageMaker import PackageMaker

config_file = 'release_config'

class ReleaseUtilities:

	def __init__(self, libdir):
		self.true = 1
		self.false = 0
		self.work_dir_word = "work_directory"
		self.source_dir_word = "source_directory"
		self.package_word = "package"
		self.target_dir_word = "target_directory"
		self.relname_word = "release_name"
		self.source_files = []
		self.target_files = []
		self.source_directory = ''
		self.work_directory = ''
		# packages is a hash table - key: package names; value: list of
		# all target files in a package 
		self.packages = {}
		self.keyword_table = {self.source_dir_word: self.set_source,
						self.work_dir_word: self.set_work,
						self.package_word: self.add_package,
						self.relname_word: self.set_release_name,
						self.target_dir_word: self.set_target_dir}
		# Read configuration file and set up source directory,
		# work directory, ...
		if not (libdir == ''):
			config_file_path = libdir + '/' + config_file
		else:
			config_file_path = config_file
		file = open(config_file_path)
		for line in file.readlines():
			record = split(line)
			key = record[0]
			value = record[1]
			if self.keyword_table.has_key(key):
				self.keyword_table[key](value)
		file.close()
		if self.source_directory == '' or self.work_directory == '':
			raise "Source or work directory not set."
		else:
			self.packager = PackageMaker(self.work_directory,
				self.target_dir)

	def check_settings(self):
		error = self.false
		if len(self.source_directory) == 0:
			print 'Error: source_directory not set'
			error = self.true
		if len(self.work_directory) == 0:
			print 'Error: work_directory not set'
			error = self.true
		if error:
			print 'Exiting ...'
			sys.exit(-1)

	# Add `f' to the source file list.
	def add_source_file(self, f):
		self.source_files.append(f)

	# Add `f' to the target file list.
	def add_target_file(self, f):
		self.target_files.append(f)

	# Add (`src_path', `tgt_path') to each package identified by `keys'.
	def add_to_packages(self, src_path, tgt_path, keys):
		for k in keys:
			if not self.packages.has_key(k):
				print "Error: No package " + k + " found."
			else:
				self.packages[k].append((src_path, tgt_path))

	# Copy source files to target files.
	def copy(self):
		dos_str = "[dos]"; dslen = len(dos_str)
		self.make_work_dir()
		if len(self.source_files) != len(self.target_files):
			raise 'Source file and target file lists are different lengths.'
		os.chdir(self.source_directory)
		for i in range(len(self.source_files)):
			dos_cnv = 0
			tgpath = self.target_files[i]
			if tgpath[len(tgpath) - dslen:] == dos_str:
				dos_cnv = 1
				self.target_files[i] = tgpath[:-dslen]
			self.do_copy(self.source_files[i], self.target_files[i], dos_cnv)
		self.clean_work()

	# For each p in `packages', create package p and place all
	# files defined for p into p.
	def make_packages(self):
		for k in self.packages.keys():
			self.packager.execute(k, self.packages[k])

	# Remove work directory.
	def cleanup(self):
		os.system('rm -rf ' + self.real_work_directory)

# Private - implementation

	# Set the source directory to `s'.
	def set_source(self, s):
		self.source_directory = s

	# Set the work directory to `s'.
	def set_work(self, s):
		self.work_directory = s

	# Set the work directory to `s'.
	def set_release_name(self, s):
		self.real_work_directory = self.work_directory
		self.work_directory = self.work_directory + '/' + s

	# Add the package `s' to `packages'.
	def add_package(self, s):
		self.packages[s] = []

	# Set the target directory to `s'.
	def set_target_dir(self, s):
		self.target_dir = s

	# Clean garbage (such as CVS directories) from work directory.
	def clean_work(self):
		os.system("find " + self.work_directory +
			" -name CVS -exec rm -rf {} \; 2>/dev/null")

	def do_copy(self, srcpath, tgtpath, dos_convert):
		cmd = ''; doscnvrt_cmd = 'cnvrt_todos'
		if tgtpath == '.':
			cmd = 'cp -fRPr ' + srcpath + ' ' + self.work_directory
		else:
			work_dir = ''
			if os.path.isdir(srcpath):
				work_dir = self.work_directory + '/' + tgtpath
				cmd = 'cp -fRr ' + srcpath + ' ' + work_dir
			elif os.path.isfile(self.strip_char(srcpath, "\\")):
				work_dir = self.work_directory + '/' + \
					os.path.dirname(tgtpath)
				cmd = 'cp -f ' + srcpath + ' ' + self.work_directory + \
					'/' + tgtpath
				if dos_convert:
					cmd = cmd + '; ' + doscnvrt_cmd + ' ' + \
						self.work_directory + '/' + tgtpath
			else:
				print srcpath + ' is not a file or directory - skipping ...'
			# If the work directory doesn't exist yet, make it:
			if not os.path.isdir(work_dir):
				cmd = 'mkdir -p ' + self.work_directory + '/' + tgtpath + \
					'; ' + cmd
		os.system(cmd)

	# Make the work directory if it doesn't yet exist.
	def make_work_dir(self):
		if not os.path.exists(self.work_directory):
			os.system('mkdir -p ' + self.work_directory);

	# Strip all occurrences of `c' from `s'.
	def strip_char(self, s, c):
		return join(split(s, c), '')
