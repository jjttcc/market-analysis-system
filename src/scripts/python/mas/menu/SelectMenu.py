from ma_menu import Menu
from constants import *
from sys import *

# Menu for selecting a market
class SelectMenu(Menu):
#!!!Needs to make sure that selection within the bounds of the market list.
	def execute(self):
		self.send_key()
		self.display_current_menu()
		response = stdin.readline()
		self.connection.send_message(response)	# Send with '\n'
		print 'SelectMenu, handle_response sent ' + response
