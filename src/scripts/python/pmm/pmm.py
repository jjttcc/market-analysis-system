# pmm classes and operations
from regex import match
from regsub import split, gsub, sub
from utilities import Date
from string import lower
from pmm_settings import *
from posixpath import exists
from db_utilities import *

Debugging_on = 1

def debug(s):
	if Debugging_on: print s

# Trading signal
class Signal:
	def __init__ (self, symbol, date, event_line):
		self.symbol = symbol
		self.date = date
		self._event_line = event_line

	def is_buy(self):
		result = match(buy_string, self._event_line) != -1
		return result

	def is_sell(self):
		result = match(sell_string, self._event_line) != -1
		return result

	def is_sidelined(self):
		result = match(sideline_string, self._event_line) != -1
		return result

	def __str__ (self):
		if self.is_buy(): buysell = "buy"
		elif self.is_sell(): buysell = "sell"
		elif self.is_sidelined(): buysell = "sidelined"
		else: buysell = "None"
		return "symbol: '" + self.symbol + "', date: '" + \
			self.date.as_string() + "', buy/sell/sidel: " + buysell +\
			", event: '" + self._event_line + "'"

# Unique signals extracted from msg.  When more than one signal occurs for
# the same symbol, the signal with the latest date is extracted.
def unique_signals(msg):
	signal_table = {}
	for line in msg:
		line = line[:-1]
		if match(event_string, line) != -1:
			#print 'line is "' + line + '"'
			symbol = sub(symbol_regex, symbol_regsub, line)
			date = sub(date_regex, date_regsub, line)
			#print 'symbol, date: "' + symbol + '", "' + date + '"'
			ymd = split(date, "/")
			year = 0; month = 0; day = 0
			year = eval(ymd[2])
			month = eval(sub("^0", "", ymd[0]))
			day = eval(sub("^0", "", ymd[1]))
			signal_date = Date(year, month, day)
			signal = Signal(symbol, signal_date, line)
			if signal_table.has_key(symbol):
				#print 'Adding signal ',; print signal
				signal_table[symbol].append(signal)
			else:
				#print 'Putting signal ',; print signal
				signal_table[symbol] = [signal]
	signal_list = []
	for symbol in signal_table.keys():
		signals = signal_table[symbol]
		last_signal = signals[0]
		for i in range(1, len(signals)):
			if signals[i].date > last_signal.date:
				last_signal = signals[i]
		#print '<<<Appending signal ',; print last_signal,;print '>>>'
		signal_list.append(last_signal)
	return signal_list

# Remove `sym' from file `path'.
def remove_from_file(path, sym):
	symbol = lower(sym)
	symbol_in_file = 0
	debug("Removing " + symbol + " from " + path)
	if exists(path):
		file = open(path, "r")
		newcontents = []
		for line in file.readlines():
			l = line[:-1]
			if l != symbol:
				newcontents.append(line)
			else:
				symbol_in_file = 1
				#debug("\tline " + l + " matches the symbol " + symbol)
		file.close()
		if symbol_in_file:
			file = open(path, "w")
			file.writelines(newcontents)
		else:
			debug("symbol " + sym + ' is not in file ' + path)
	else:
		debug(path + " does not exist - doing nothing.")

# Add `sym' to file `path'.
def add_to_file(path, sym):
	symbol = lower(sym)
	debug("Adding " + symbol + " to " + path)
	if exists(path):
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
	else:
		newcontents = [symbol + "\n"]
		debug(path + " does not exist - creating it.")
	file = open(path, "w")
	file.writelines(newcontents)

# If signal is a buy signal, add it to the uptrend list and (if it's there)
# remove it from the downtrend list; if it is a sell signal, add it to the
# downtrend list and remove it from the uptrend list.  If it is a sidelined
# signal, remove it from the buy/sell lists and add it to the sidelined list.
def update_trend_lists(signals, upfile_path, downfile_path, sidefile_path):
	for s in signals:
		debug('Updating trend lists for signal "' + s.__str__() + '"')
		if s.is_buy():
			debug(s.symbol + ' is a buy')
			remove_from_file(downfile_path, s.symbol)
			remove_from_file(sidefile_path, s.symbol)
			add_to_file(upfile_path, s.symbol)
		elif s.is_sell():
			debug(s.symbol + ' is a sell')
			remove_from_file(upfile_path, s.symbol)
			remove_from_file(sidefile_path, s.symbol)
			add_to_file(downfile_path, s.symbol)
		elif s.is_sidelined():
			debug(s.symbol + ' is a sideline')
			remove_from_file(upfile_path, s.symbol)
			remove_from_file(downfile_path, s.symbol)
			add_to_file(sidefile_path, s.symbol)
		else:
			print 'Warning: event for ' + s.symbol + ' does not match ' +\
				'buy, sell or sidelined specification:'
			print s

# Update trend lists in the database.
# If signal is a buy signal, add it to the uptrend list and (if it's there)
# remove it from the downtrend list; if it is a sell signal, add it to the
# downtrend list and remove it from the uptrend list.  If it is a sidelined
# signal, remove it from the buy/sell lists and add it to the sidelined list.
# watch_flags[0] is the flag for the uptrend list; watch_flags[1] is the
# flag for the downtrend list; watch_flags[2] is the flag for the sidelined
# list.
# Precondition: len(watch_flags) == 3
def db_update_trend_lists(signals, watch_flags):
	assert(len(watch_flags) == 3)
	upflag = watch_flags[0]
	downflag = watch_flags[1]
	sideflag = watch_flags[2]
	remove_list = []
	add_list = []
	for s in signals:
		debug('Updating trend lists for signal "' + s.__str__() + '"')
		# Symbols are stored in lower case.
		symbol = lower(s.symbol)
		if s.is_buy():
			debug(s.symbol + ' is a buy')
			remove_list.append((symbol, downflag))
			remove_list.append((symbol, sideflag))
			add_list.append((symbol, upflag))
		elif s.is_sell():
			debug(s.symbol + ' is a sell')
			remove_list.append((symbol, upflag))
			remove_list.append((symbol, sideflag))
			add_list.append((symbol, downflag))
		elif s.is_sidelined():
			debug(s.symbol + ' is a sideline')
			remove_list.append((symbol, upflag))
			remove_list.append((symbol, downflag))
			add_list.append((symbol, sideflag))
		else:
			print 'Warning: event for ' + s.symbol + ' does not match ' +\
				'buy, sell or sidelined specification:'
			print s
	add_to_watch_list(add_list)
	remove_from_watch_list(remove_list)
