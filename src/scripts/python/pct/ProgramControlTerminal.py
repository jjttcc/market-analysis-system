import os
import sys
import string
import regex
from PCT_Window import PCT_Window
import Tkinter

class Prog_name:

	def __init__(self):
		self.program_name = ''

pname = Prog_name()

def abort(msg):
	if pname.program_name != '': print pname.program_name + ": ",
	else: print "Fatal Error - ",
	if msg != None:
		print msg + " - ",
	print "Exiting ..."
	sys.exit(-1)

# Dynamically import `modules' and execute `cmd'.
# Set args to empty string to indicate there are not arguments.
def import_and_execute(modules, cmd, args):
	assert(modules != None and cmd != None and args != None)
	#print 'import_and_execute called with cmd: ',;print cmd
	for m in modules:
		import_stmt = 'from ' + m + ' import *'
		try:
			#print 'execing ' + import_stmt
			exec import_stmt
			#print 'Execution of ' + import_stmt + ' succeeded.'
		except:
			abort('Execution of ' + import_stmt + ' failed.')
	complete_cmd = cmd + '('
	if args != []:
		lastarg = ''
		if 1:
			i = -1
			for i in range(0, len(args) - 1):
				lastarg = args[i]
				complete_cmd = complete_cmd + lastarg + ', '
			lastarg = args[i+1]
			complete_cmd = complete_cmd + lastarg
			#abort("Error parsing argument " + lastarg + " to " + cmd + \
			#	"\n(They must" + " be strings, not numbers.)")
	complete_cmd = complete_cmd + ')'
	#print 'exececuting "result = ' + complete_cmd + '"'
	exec "result = " + complete_cmd
	return result

# ProgramControlTerminal Component
class PCT_Component:

	def __init__(self):
		self.terminal_name = ''
		self.prompt = ''
		self.startup_cmd = ''
		self.startup_cmd_args = []
		self.config_file_name = ''
		self.program_name = ''
		self.import_modules = []
		self.exit_after_startup_cmd = 0

	def __repr__(self):
		return self.terminal_name + ', ' + self.prompt + ', ' + \
			self.startup_cmd + ', ' + self.config_file_name

	def set_startup_cmd(self, cmd):
		if regex.match(".*(", cmd) != -1:
			abort("Parentheses are not allowed in config. file " +\
				"startup_cmd spec.\n(Command was '" + cmd + "'.)")
		else:
			self.startup_cmd = cmd

	# Add an argument to startup_cmd.
	def add_cmd_arg(self, arg):
		self.startup_cmd_args.append(arg)

	# Prepend the list `l' of arguments to startup_cmd.
	def prepend_cmd_args(self, l):
		self.startup_cmd_args = l + self.startup_cmd_args

	# Import the import_modules and execute startup_cmd.
	def exec_startup_cmd(self):
		#print 'setting up cmd with imports: '
		#print self.import_modules
		if self.config_file_name != '':
			# If there is a config file, a sub-terminal needs to be run.
			pct = ProgramControlTerminal(self.config_file_name,
				self.program_name)
			pct.run_command(self)
		else:
			r = import_and_execute(self.import_modules, self.startup_cmd,
				self.startup_cmd_args)
			#print 'result was ',; print r

# ProgramControlTerminal utility functions
class PCT_Tools:

	def set_program_name(self, s):
		pname.program_name = s

	def config_file_from_python_path(self, cfname):
		result = None
		try:
			pypath = os.environ['PYTHONPATH']
		except:
			abort("PYTHONPATH environment variable is not set.")
		for dir in string.split(pypath, ":"):
			cfpath = dir + os.sep + cfname
			try:
				result = open(cfpath, "r", 0)
			except:
				None # null statement
		if result == None:
			abort("Configuration file " + cfname + " not found.")
		return result

	# Open, readable file from `cfname'
	# Precondition: cfname != None
	def config_file(self, cfname):
		assert(cfname != None)
		result = None
		try:
			result = os.environ["PCT_CONFIG_FILE"]
		except:
			result = self.config_file_from_python_path(cfname)
		return result

	def comment(self, l):
		result = l[0] == '#'
		return result

	# Field separator exctracted from `lines'
	# Precondition: lines != None
	def separator(self, lines):
		assert(lines != None)
		result = '\t'
		for line in lines:
			line = line[:-1]
			if not self.comment(line):
				words =  string.split(line, "=")
				if words[0] == 'separator':
					result = words[1]
					if len(result) > 0:
						break
					else:
						abort("invalid separator spec. in config file: '" +\
							line + "'")
		return result

class ProgramControlTerminal(PCT_Tools):

	# Precondition:
	#    config_file is an existing file open for reading.
	def __init__(self, config_file_name, program_name):
		self.set_program_name(program_name)
		cfgfile = self.config_file(config_file_name)
		lines = cfgfile.readlines()
		sep = self.separator(lines)
		self.window_title = 'Program Control Panel'
		self.quit = 0
		self.parse_and_process(lines, sep)
		self.window = PCT_Window(self.window_title)
		for c in self.subcomponents:
			self.window.add_button(c)
		if self.quit:
			self.window.add_quit_button()

	# Dynamically import `modules' and execute `cmd'.
	def run_command(self, component):
		modules = component.import_modules; cmd = component.startup_cmd
		args = component.startup_cmd_args
		result = import_and_execute(modules, cmd, args)
		# The result, if any, is expected to specify arguments for the
		# subcomponents' startup command.
		for c in self.subcomponents:
			c.prepend_cmd_args(result)
		#print 'run_command result was ',; print result

	def execute(self):
		self.window.mainloop()

	# Parse and process `lines' using separator `sep'.
	def parse_and_process(self, lines, sep):
		self.subcomponents = []
		in_sub = 0
		for l in lines:
			if self.comment(l): continue
			tuple = string.split(l, sep)
			tuple_name = tuple[0]
			if tuple_name == 'terminal_name':
				self.window_title = tuple[1][:-1]
			elif tuple_name == "quitbutton":
				self.quit = 1
			elif regex.match("^begin", tuple_name) != -1:
				current_sub = PCT_Component()
				in_sub = 1
			elif regex.match("^end", tuple_name) != -1:
				current_sub.program_name = pname.program_name
				self.subcomponents.append(current_sub)
				in_sub = 0
			elif in_sub:
				if tuple_name == "terminal_name":
					current_sub.terminal_name = tuple[1][:-1]
				elif tuple_name == "prompt":
					current_sub.prompt = tuple[1][:-1]
				elif tuple_name == "startup_cmd":
					current_sub.set_startup_cmd(tuple[1][:-1])
				elif tuple_name == "config_file_name":
					current_sub.config_file_name = tuple[1][:-1]
				elif tuple_name == "cmd_args":
					current_sub.add_cmd_arg(tuple[1][:-1])
				elif tuple_name == "exit_after_startup_cmd":
					current_sub.exit_after_startup_cmd = 1
				elif tuple_name == 'import_module':
					spec = tuple[1][:-1]
					if not in_sub:
						abort("Error in cofig. file:\n" + \
							"Import spec. " + spec + " not within " + \
							"sub-terminal spec.")
					else:
						current_sub.import_modules.append(tuple[1][:-1])
			else:
				if regex.match("^separator", l) == -1:
					print "Invalid line in config. file: " + l,
					print "May be invalid because it is outside of a " + \
						"sub-terminal spec."
