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
		self.select_patterns = ["Select[^?]*function",
			"Select[^?]*opera[nt][do]",
			"Select the technical indicator"]
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
			response = sub(self.shared_pattern, "", response)
			shared = true
		else:
			otable = self.objects
		if self.selection and otable.has_key(response):
			self.result = otable[response]
			key_matched = true
		else:
			self.result = response
		if self.record:
			self.record_input(self.result, shared, key_matched)
		self.result = self.result + '\n'

	def select_object_match(self, s):
		result = false
		for pattern in self.select_patterns:
			if match(pattern, s) != -1:
				result = true
				break
		return result

	def store_choices(self, s):
		self.objects.clear(); self.shared_objects.clear()
		lines = split(s, '\n')
		for l in lines:
			if match("^[1-9][0-9]*)", l) != -1:
				l = sub(")", "", l)
				objnumber = sub(" .*", "", l)
				objname = sub("^[^ ]*  *", "", l)
				self.objects[objname] = objnumber
			elif match(self.non_shared_pattern, l) != -1 and \
					len(self.objects) > 0:
				self.shared_objects = self.objects.copy()
				self.objects.clear()

	def record_input(self, s, shared, key_match):
		if self.selection:
			if key_match:
				if shared:
					self.input_record = self.input_record + \
						self.shared_string + key + '\n'
				else:
					self.input_record = self.input_record + key + '\n'
			elif s in self.objects.values():
				self.input_record = self.input_record + \
					self.key_for(s, self.objects) + '\n'
			elif s in self.shared_objects.values():
				self.input_record = self.input_record + self.shared_string + \
					self.key_for(s, self.shared_objects) + '\n'
		else:
			self.input_record = self.input_record + self.result + '\n'

	def key_for(self, s, objects):
		result = ''
		for k in objects.keys():
			if objects[k] == s:
				result = k
		return result
