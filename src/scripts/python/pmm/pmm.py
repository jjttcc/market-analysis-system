# pmm classes and operations
from regex import match
from regsub import split, gsub, sub
from utilities import Date
from string import lower

Debugging_on = 1

def debug(s):
	if Debugging_on: print s

# Trading signal
class Signal:
	def __init__ (self, symbol, date, buy):
		self.symbol = symbol
		self.date = date
		self._is_buy = buy

	def is_buy(self):
		return self._is_buy

	def is_sell(self):
		return not self._is_buy

	def __str__ (self):
		if self.is_buy(): buysell = "buy"
		else: buysell = "sell"
		#return self.symbol + ", " + self.date + ", " + buysell
		return self.symbol + ", " + self.date.as_string() + ", " + buysell

# Unique signals extracted from msg.  When more than one signal occurs for
# the same symbol, the signal with the latest date is extracted.
def unique_signals(msg):
	buy_string = "(Buy)"
	signal_table = {}
	for line in msg:
		if match("^Event for:", line) != -1:
			line = gsub(",", "", line)
			fields = split(line, " ")
			assert(fields[0] == "Event")
			assert(fields[1] == "for:")
			symbol = fields[2]
			assert(fields[3] == "date:")
			date = fields[4]
			ymd = split(date, "/")
			year = 0; month = 0; day = 0
			year = eval(ymd[2]);# month = eval(ymd[0]); day = eval(ymd[1])
			month = eval(sub("^0", "", ymd[0]))
			day = eval(sub("^0", "", ymd[1]))
			signal_date = Date(year, month, day)
			buy_sell = fields[len(fields) - 1][:-1]
			signal = Signal(symbol, signal_date, buy_sell == buy_string)
			#print signal
			if signal_table.has_key(symbol):
				signal_table[symbol].append(signal)
			else:
				signal_table[symbol] = [signal]
	signal_list = []
	for symbol in signal_table.keys():
		signals = signal_table[symbol]
		last_signal = signals[0]
		for i in range(1, len(signals)):
			if signals[i].date > last_signal.date:
				last_signal = signals[i]
		signal_list.append(last_signal)
	return signal_list

def remove_from_file(path, sym):
	symbol = lower(sym)
	debug("Removing " + symbol + " from " + path)
	file = open(path, "r")
	newcontents = []
	for line in file.readlines():
		l = line[:-1]
		if l != symbol:
			newcontents.append(line)
		else:
			debug("\tline " + l + " matches the symbol " + symbol)
	file.close()
	file = open(path, "w")
	file.writelines(newcontents)

def add_to_file(path, sym):
	symbol = lower(sym)
	debug("Adding " + symbol + " to " + path)
	file = open(path, "r")
	newcontents = []
	for line in file.readlines():
		l = line[:-1]
		if l == symbol:
			debug(l + " is already in " + path)
			return
		newcontents.append(line)
	newcontents.append(symbol + "\n")
	newcontents.sort()
	file.close()
	file = open(path, "w")
	file.writelines(newcontents)

# If signal is a buy signal, add it to the uptrend list and (if it's there)
# remove it from the downtrend list; if it is a sell signal, add it to the
# downtrend list and remove it from the uptrend list.
def update_trend_lists(signals, upfile_path, downfile_path):
	for s in signals:
		debug('Updating trend lists for signal "' + s.__str__() + '"')
		if s.is_buy():
			remove_from_file(downfile_path, s.symbol)
			add_to_file(upfile_path, s.symbol)
		else:
			assert(s.is_sell())
			remove_from_file(upfile_path, s.symbol)
			add_to_file(downfile_path, s.symbol)
