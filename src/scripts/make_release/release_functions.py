# Utility functions for making releases

import os
from sys import *
from __builtin__ import open
from string import *
from PackageMaker import PackageMaker

class ReleaseUtilities:

	def __init__(self):
		self.true = 1
		self.false = 0
		self.target_dir_word = "target_directory"
		self.source_dir_word = "source_directory"
		self.package_word = "package"
		self.package_dir_word = "package_dir"
		self.source_files = []
		self.target_files = []
		self.source_directory = ''
		self.target_directory = ''
		# packages is a hash table - key: package names; value: list of
		# all target files in a package 
		self.packages = {}
		self.source_directory = ""
		self.target_directory = ""
		self.keyword_table = {self.source_dir_word: self.set_source,
						self.target_dir_word: self.set_target,
						self.package_word: self.add_package,
						self.package_dir_word: self.set_package_dir}
		# Read configuration file and set up source directory,
		# target directory, ...
		file = open('release_config')
		for line in file.readlines():
			record = split(line)
			key = record[0]
			value = record[1]
			if self.keyword_table.has_key(key):
				self.keyword_table[key](value)
		file.close()
		if self.source_directory == '' or self.target_directory == '':
			raise "Source or target directory not set."
		else:
			self.packager = PackageMaker(self.target_directory,
				self.package_dir)

	def check_settings(self):
		error = self.false
		if len(self.source_directory) == 0:
			print 'Error: source_directory not set'
			error = self.true
		if len(self.target_directory) == 0:
			print 'Error: target_directory not set'
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
		self.make_target_dir()
		if len(self.source_files) != len(self.target_files):
			raise 'Source file and target file lists are different lengths.'
		os.chdir(self.source_directory)
		for i in range(len(self.source_files)):
			self.do_copy(self.source_files[i], self.target_files[i])
		self.clean_target()

	# For each p in `packages', create package p and place all
	# files defined for p into p.
	def make_packages(self):
		for k in self.packages.keys():
			self.packager.execute(k, self.packages[k])

	# Remove target directory.
	def cleanup(self):
		os.system('rm -rf ' + self.target_directory)

# Private - implementation

	# Set the source directory to `s'.
	def set_source(self, s):
		self.source_directory = s

	# Set the target directory to `s'.
	def set_target(self, s):
		self.target_directory = s

	# Add the package `s' to `packages'.
	def add_package(self, s):
		self.packages[s] = []

	# Set the package directory to `s'.
	def set_package_dir(self, s):
		self.package_dir = s

	# Clean garbage (such as CVS directories) from target directory.
	def clean_target(self):
		os.system("find " + self.target_directory +
			" -name CVS -exec rm -rf {} \; 2>/dev/null")

	def do_copy(self, srcpath, tgtpath):
		cmd = ''
		if tgtpath == '.':
			cmd = 'cp -fRPr ' + srcpath + ' ' + self.target_directory
		else:
			target_dir = ''
			if os.path.isdir(srcpath):
				target_dir = self.target_directory + '/' + tgtpath
				cmd = 'cp -fRr ' + srcpath + ' ' + target_dir
			elif os.path.isfile(self.strip_char(srcpath, "\\")):
				target_dir = self.target_directory + '/' + \
					os.path.dirname(tgtpath)
				cmd = 'cp -f ' + srcpath + ' ' + self.target_directory + \
					'/' + tgtpath
			else:
				print srcpath + ' is not a file or directory - skipping ...'
			# If the target directory doesn't exist yet, make it:
			if not os.path.isdir(target_dir):
				cmd = 'mkdir -p ' + self.target_directory + '/' + tgtpath + \
					'; ' + cmd
		os.system(cmd)

	# Make the target directory if it doesn't yet exist.
	def make_target_dir(self):
		if not os.path.exists(self.target_directory):
			os.system('mkdir ' + self.target_directory);

	# Strip all occurrences of `c' from `s'.
	def strip_char(self, s, c):
		return join(split(s, c), '')
