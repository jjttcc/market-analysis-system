from sys import *
from ma_menu import Menu

class ExitMenu(Menu):
	def execute(self):
			self.send_key()
			exit(0)
