# Provides socket connection facilities for Market Analysis command-line
# clients.

from socket import *
from ma_protocol import *
from string import *
from constants import *

class Connection(Protocol):
	# Create socket, connect to host, and send initial request.
	def __init__(self, host, port):
		self.verbose = 0
		self.Buffersize = 1
		self.init_protocol()
		self.socket = socket(AF_INET, SOCK_STREAM)
		self.socket.connect((host, port))
		if self.verbose: print 'Connected to ' + host
		self.termination_requested = 0
		self.last_message = ''
		# Notify server that this is a command-line client.
		self.send_message(Command_line)

	# Receive the last requested message, put result in last_message.
	def receive_message(self):
		self.last_message = ''
		msg = []
		while 1:
			c = self.socket.recv(self.Buffersize)
			if c == self.EOM or c == self.EOF: break
			msg.append(c)
		if c == self.EOF:
			self.termination_requested = 1
		self.last_message = join(msg, '')

	def send_message(self, msg):
		self.socket.send(msg)

	# Close the connection.
	def close(self):
		self.socket.close()
