from ma_menu import *
from CreateIndicatorMenu import *
from ExitMenu import *
from MAClientMenuBuilder import *
from MainEditIndicatorMenu import *
from PreviousMenu import *
from SelectMenu import *

class MenuSpecification:
	def __init__(self, connection):
		self.connection = connection
		self.main_menu = Menu(self.connection)
		self.set_constants()
		self.create_menus()
		# Format for tree tuples: (<subtree>, <menu>)
		self.main_edit_indicator_tree = \
			{self.Create_indicator: ({}, self.menus[self.Create_indicator]),
				self.Main_prev: ({}, self.menus[self.Main_prev]),
				self.Exit: ({}, self.menus[self.Exit])}
		self.tree = {self.Select: ({}, self.menus[self.Select]),
			self.Select_prev: ({}, self.menus[self.Select_prev]),
			self.Main_edit_indicator: (self.main_edit_indicator_tree,
				self.menus[self.Main_edit_indicator]),
			self.Exit: ({}, self.menus[self.Exit])}

	# The menu contained in `tuple'
	def menu_at(self, tuple):
		return tuple[1]

	# The tree contained in `tuple'
	def tree_at(self, tuple):
		return tuple[0]

#!!!Check - no self argument - does this make it 'private' or does it
#not work?
	def set_constants(self):
		self.Create_indicator = 'c'
		self.Exit = 'x'
		self.Select = 's'
		self.Main_edit_indicator = 'e'
		self.Main_prev = '-'
		self.Select_prev = '-'
		self.Main_edit_prev = '-'

	def create_menus(self):
		self.menus = {}
		self.menus[self.Select] = self.select_menu()
		self.menus[self.Main_edit_indicator] = self.main_edit_indicator_menu()
		self.menus[self.Main_prev] = self.main_prev_menu()
		self.menus[self.Exit] = self.exit_menu()
		self.menus[self.Create_indicator] = self.create_indicator_menu()
		self.menus[self.Select_prev] = self.select_prev_menu()
		self.menus[self.Main_edit_prev] = self.main_edit_ind_prev_menu()

	def select_menu(self):
		return SelectMenu(self.connection, self.main_menu, self.Select)

	def exit_menu(self):
		return ExitMenu(self.connection, self.main_menu, self.Exit)

	def main_edit_indicator_menu(self):
		return MainEditIndicatorMenu(self.connection, self.main_menu,
			self.Main_edit_indicator)

	def main_prev_menu(self):
		return PreviousMenu(self.connection, self.main_menu, self.Main_prev)

	def create_indicator_menu(self):
		return CreateIndicatorMenu(self.connection,
			self.menus[self.Main_edit_indicator], self.Create_indicator)

	def select_prev_menu(self):
		return PreviousMenu(self.connection, self.menus[self.Select],
			self.Select_prev)

	def main_edit_ind_prev_menu(self):
		return PreviousMenu(self.connection,
			self.menus[self.Main_edit_indicator], self.Main_edit_prev)
