import os
import time

if os.system('connectppp &') != 0:
	self.error = "Was not able to establish ppp connection."
connected = 0
while not connected:
	time.sleep(5)
	if os.system('pppconnected') == 0: connected = 1
