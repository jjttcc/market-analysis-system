import os

# Spawn a `prog' with arguments `args' and connect stdin to the process's
# stdout and stdout to the process's stdin.
def spawn(prog, args):
	pipe1 = os.pipe()			# parent stdin, child stdout: (in, out)
	pipe2 = os.pipe()			# child stdin, parent stdout: (in, out)
	pid = os.fork()
	if pid != 0:				# If this is the parent process:
		os.close(pipe1[1])		# close child ends
		os.close(pipe2[0])
		os.dup2(pipe1[0], 0)	# sys.stdin = pipe1[0]
		os.dup2(pipe2[1], 1)	# sys.stdout = pipe2[1]
	else:						# Child process
		args = [prog] + args
		print prog + ', ',; print args
		os.close(pipe1[0])		# close parent ends
		os.close(pipe2[1])
		os.dup2(pipe1[1], 1)	# sys.stdout = pipe1[1]
		os.dup2(pipe2[0], 0)	# sys.stdin = pipe2[0]
		os.execv(prog, args)
