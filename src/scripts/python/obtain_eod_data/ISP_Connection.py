import os
import time

class ISP_Connection:
	def connect(self):
		if os.system('pppconnected') != 0:
			self.was_connected = 0
			if os.system('connectppp &') != 0:
				self.error = "Was not able to establish ppp connection."
			connected = 0
			while not connected:
				time.sleep(5)
				if os.system('pppconnected') == 0: connected = 1
		else:
			self.was_connected = 1

	def disconnect(self):
		if not self.was_connected:
			os.system('killppp')
