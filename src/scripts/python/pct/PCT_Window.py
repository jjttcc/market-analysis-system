#!/usr/bin/env python

from Tkinter import *
from Dialog import Dialog

class PCT_Window(Frame):

	# Create and pack a new button object with label txt.  Return the object.
	def button(self, txt):
		btnwidth = 35
		result = Button(self, text = txt)
		result.pack()
		result.config(width = btnwidth)
		return result

	def __init__(self, title):
		self.root = Tk()
		self.root.title(title)
		Frame.__init__(self, self.root)
		Pack.config(self)

	def add_quit_button(self):
		b = self.button("Quit")
		b.config(command = self.quit)

	def add_button(self, component):
		b = self.button(component.prompt)
		b.config(command = lambda x = self, y = component:
			PCT_Window.launch(x, y))

	def launch(self, c):
		c.exec_startup_cmd()
		if c.exit_after_startup_cmd:
			self.root.destroy()

	def createWidgets(self):
		Label(self, text = 'Hello popup world').pack(side = TOP)
		Button(self, text = 'Pop1', command = self.dialog1).pack()
		Button(self, text = 'Pop2', command = self.dialog2).pack()
		Button(self, text = 'Hey', command = self.greet).pack(side = LEFT)
		Button(self, text = 'Bye', command = self.quit).pack(side = RIGHT)

	def dialog1(self):
		ans = Dialog(self, title = "Popup Fun!",
				text = 'An example of a popup-dialog box.  "Dialog.py"'
						'has a simple interface for canned dialogs.',
				bitmap = 'questhead', default = 0,
				strings = ('Yes', 'No', 'Cancel'))
		if ans.num == 0:
			self.dialog2()

	def dialog2(self):
		Dialog(self, title = 'HAL-9000',
			text = "I'm afraid I can't let you do that, Dave...",
			bitmap = 'hourglass', default = 0, strings = ('spam', 'SPAM'))

