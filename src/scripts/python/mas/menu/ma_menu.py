# Currently, execute just loops, sending user input to the server and
# printing the response.  Later, a menu hierarchy can be built, using
# the submenus attribute, so that the menu hierarchy will match the
# command-line menu hieararchy of the server.  This will allow intelligence
# to be added to menus to improve formatting, apply rules (especially for
# command, function, and market analyzer editing), and possibly to display
# the menu in a GUI.
# Another use of this hierarchy with respect to function, etc., editing is
# to allow the user to record the commands needed to, for example, build a
# particular function, so that it can be played back later to re-build
# the function.  (This would be based on command/function names rather than
# the selection number used to choose one of these items, so that changes
# in the order and number of items will not affect the playback.  Use
# something like a hash table of command and function names for this.)

from sys import *
from constants import *

class Menu:
	def __init__(self, conn, parent = None, key = ''):
		self.connection = conn
		self.finished = false
		self.parent = parent
		self.key = key
		self.submenus = {}
		print 'menu key set to ' + self.key

	def execute(self):
		self.finished = false
		print 'menu execute called'
		print 'menu key is ' + self.key
		self.send_key()
		self.display_current_menu()
		while not self.finished:
			print '\nkey: ' + self.key
			print 'self.finished (before proc_resp): '; print self.finished
			self.process_response()
			print 'self.finished (after proc_resp): '; print self.finished
			if not self.finished:
				self.display_current_menu()

# Private - implementation

	def process_response(self):
			response = stdin.readline()[:-1] # with newline stripped
			print 'user response was "' + response + '"'
			print 'keys: '; print self.submenus.keys()
			if self.submenus.has_key(response):
				print 'calling execute on '; print self.submenus[response]
				self.submenus[response].execute()
			else:
				self.handle_response(response)

	def display_current_menu(self):
		print 'display_current_menu called'
		self.connection.receive_message()
		print self.connection.last_message,

# Private - hook methods

	# Handle a response that is not covered by submenus.
	# Default implementation: send `r' + '\n' to server
	def handle_response(self, r):
		self.connection.send_message(r + '\n')
		print 'handle response sent "' + r + '\n"'

	def send_key(self):
		if not self.key == '':
			self.connection.send_message(self.key + "\n")
			print 'sent "' + self.key + '\n"'
