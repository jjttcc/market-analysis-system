from os import *
from mas_settings import *
from whrandom import *
import sys
import regex

randobj = whrandom()

# Random port number - as a string
def randport():
	result = randobj.randint(1024, 65535)
	return '%d' % (result)

# Obtain a port number from the user.
def obtain_port_number():
	while 1:
		try:
			print "Enter the server's port number. ",
			port = sys.stdin.readline()[:-1]
			num = eval(port)
		except:
			print 'Invalid input.'
			continue
		if num < 1024:
			print 'You entered ' + port + ' (less than 1024).'
			print 'Do you really want to use that port number? ',
			answer = sys.stdin.readline()
			if regex.match("^[yY]", answer) != -1:
				break
		else: break
	return port

# Start the MAS server with a random port number.
def start_server():
	chdir(datadir)
	port = randport()
	if fork() == 0:
		args = masargs
		args.append(port)
		execv(mascmd, args)
		print "Error executing " + mascmd
	# Result must be a list.
	return [port]

# Start the MAS command-line client.  If `port' is not -1, it specifies the
# server's port number; otherwise, the port number is obtained from the user.
def start_client(port = -1):
	if port == -1: port = eval(obtain_port_number())
	if fork() == 0:
		args = maclargs
		args.append('%d' % port)
		cmd = maclcmd
		for w in args:
			cmd = cmd + ' ' + w
		system(cmd)
		sys.exit(0)

# Start the MAS GUI.  If `port' is not -1, it specifies the server's
# port number; otherwise, the port number is obtained from the user.
def start_gui(port = -1):
	if port == -1: port = eval(obtain_port_number())
	if fork() == 0:
		args = maguiargs
		args.append('%d' % port)
		cmd = maguicmd
		for w in args:
			cmd = cmd + ' ' + w
		system(cmd)
		sys.exit(0)

# Terminate the MAS server.  If `port' is not -1, it specifies the server's
# port number; otherwise, the port number is obtained from the user.
# If `exit', exit this process.
def terminate_server(port = -1, exit = 0):
	if port == -1: port = eval(obtain_port_number())
	if fork() == 0:
		cmd = 'echo |' + maclpath + ' ' + '%d' % port + ' >>/dev/null 2>&1'
		result = system(cmd)
		if result != 0:
			print "Failed to terminate server with port ",; print port
			print "Exit status was ",; print result
		sys.exit(result)
	else:
		if exit: sys.exit(0)
