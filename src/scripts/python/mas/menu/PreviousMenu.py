from ma_menu import Menu
from constants import *

class PreviousMenu(Menu):
	def execute(self):
		self.send_key()
		self.parent.finished = true
