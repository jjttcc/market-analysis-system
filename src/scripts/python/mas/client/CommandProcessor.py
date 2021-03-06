from constants import *
from regex import *
from regsub import *

class CommandProcessor:

	def __init__(self, record):
		self.record = record
		self.input_record = ""
		self.fatal_error = false
		self.error = false
		self.invalid_pattern = "Invalid selection"
		self.select_patterns = ["\n*Select[^?]*function",
			"\n*Select[^?]*opera[nt][do]",
			"\n*Select *an *indicator *for.*'s",
			"\n*Select *indicator *to *view",
			"\n*Select *an *object *for.*'s",
			"\n*Select *the *[a-z]* *technical indicator",
			"\n*Select *an *indicator *to *edit:",
			"Added type.*\.$",
			"User was created with the following properties:",
			".*has.*leaf.*function.*-.*",
			"Examining.*leaf.*function.*",
			"\n*Select *the.*trading *period *type.*:",
			".*\n*Select specification for crossover detection:",
			"\n* *Select *a *market *analyzer",
			" *Indicator *\".*\" *children:",
			"1) "]
		self.non_shared_pattern = ".*List of all valid objects:.*"
		self.objects = {}
		self.shared_objects = {}
		self.shared_pattern = "shared *"
		self.shared_string = "shared "

	# Set the current message from the server and, if includes an object
	# selection, save the choices for processing.
	def set_server_msg(self, msg):
		self.fatal_error = false
		self.error = false
		self.selection = false
		self.last_msg = msg
		if match(self.invalid_pattern, msg) != -1:
			self.error = true
		if self.select_object_match(msg):
			self.selection = true
			self.store_choices(msg)

	# Process the response to send to the server according to the stored
	# object choice.  If there is not current choice, result will equal
	# response; else result will be the specified choice, if there is
	# a match.  If there is no match, fatal_error will be true.
	def process(self, response):
		otable = {}
		shared = false
		key_matched = false
		if match(self.shared_pattern, response) != -1:
			otable = self.shared_objects
#			print "Using shared list"
#			print otable.items()
			response = sub(self.shared_pattern, "", response)
			shared = true
		else:
			otable = self.objects
#		print "Checking '" + response + "' with:\n"
#		print otable.items()
		if self.selection and otable.has_key(response):
			self.result = otable[response]
#			print "Matched: " + self.result
			key_matched = true
		else:
			self.result = response
#			print "No match: " + self.result
		if self.record:
			self.record_input(self.result, shared, key_matched)
		self.result = self.result + '\n'

	def select_object_match(self, s):
		result = false
#		print "Checking for match of '" + s + "'"
		for pattern in self.select_patterns:
#			print "with " + pattern
			if match(pattern, s) != -1:
				result = true
				break
#		print "returning result of ",
#		if result: print "true"
#		else: print "false"
		return result

	def store_choices(self, s):
		self.objects.clear(); self.shared_objects.clear()
		lines = split(s, '\n')
		for l in lines:
#			print "l: " + l
			if match("^[1-9][0-9]*)", l) != -1:
				l = sub(")", "", l)
				objnumber = sub(" .*", "", l)
				objname = sub("^[^ ]*  *", "", l)
				self.objects[objname] = objnumber
#				print "Stored: " + self.objects[objname] + " (" + objname + ")"
			elif match(self.non_shared_pattern, l) != -1 and \
					len(self.objects) > 0:
				self.shared_objects = self.objects.copy()
				self.objects.clear()

	def record_input(self, s, shared, key_match):
#		print "ri - s, shared, key_match: '" + s + "', " + `shared` + \
#			", " + `key_match`
		if self.selection:
			if key_match:
				if shared:
					# !!Check use of s here:
					self.input_record = self.input_record + \
						self.shared_string + s + '\n'
				else:
					# !!Check use of s here:
					self.input_record = self.input_record + s + '\n'
			elif s in self.objects.values():
#				print s + " in objects"
				self.input_record = self.input_record + \
					self.key_for(s, self.objects) + '\n'
			elif s in self.shared_objects.values():
#				print s + " in shared objects"
				self.input_record = self.input_record + self.shared_string + \
					self.key_for(s, self.shared_objects) + '\n'
			else:
#				print "adding " + s + " to input record"
				self.input_record = self.input_record + s + '\n'
		else:
#			print "adding " +  self.result + " to input record"
			self.input_record = self.input_record + self.result + '\n'

	def key_for(self, s, objects):
		result = ''
		for k in objects.keys():
			if objects[k] == s:
				result = k
#		print "key_for returning " + result
		return result
