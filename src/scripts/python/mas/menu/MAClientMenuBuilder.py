# Builder of a menu tree for the Market Analysis command-line client

from sys import *
from os import *
from math import *
from string import *
from ma_connection import *
from ma_menu import *
from menu_spec import *

class MAClientMenuBuilder:
	def __init__(self):
		self.process_args()
		self.open_connection()
		self.menu_spec = MenuSpecification(self.connection)
		self.make_menu_tree()

# private - implementation

	def usage(self):
		print "Usage: " + argv[0] + " [-h hostname] port"

	def process_args(self):
		argcount = len(argv)
		if argcount < 2:
			self.usage()
			exit(-1)
		self.host = ""
		i = 1
		while i < argcount:
			if argv[i][:2] == '-h':
				if i + 1 < argcount:
					i = i + 1
					self.host = argv[i]
				else:
					self.usage(); exit(-1)
			else:
				try:
					self.port = eval(argv[i])
				except:
					self.usage(); exit(-1)
			i = i + 1

		if self.host == "":
			f = popen("hostname")
			self.host = f.readline()[:-1]

		if self.host == "":
			print argv[0] + ": No host found."
			self.usage(); exit(-1)

	def open_connection(self):
		self.connection = Connection(self.host, self.port)

	def make_menu_tree(self):
		self.main_menu = self.menu_spec.main_menu
		self.main_menu.submenus = self.build_menu_tree(self.menu_spec.tree)

	def build_menu_tree(self, tree):
		result = {}
		for k in tree.keys():
			result[k] = self.menu_spec.menu_at(tree[k])
			result[k].submenus = \
				self.build_menu_tree(self.menu_spec.tree_at(tree[k]))
		return result
