# Exponential moving average
def ema (l, column_number, n):
	result = []
	global exp_constant
	exp_constant = 2.0/(n + 1)
	result.append(average(l, column_number, n))
	for i in range(n, len(l)):
		result.append(expcalc(eval(l[i][column_number]), result[i-n]))
	return result

# Average of the first n rows of l for column_number column
def average (l, column_number, n):
	result = 0
	for i in range(0, n):
		result = result + eval(l[i][column_number])
	result = result / n
	return result

def expcalc(value, prevexp):
	return (value - prevexp) * exp_constant + prevexp
