# MAS database utilities
#!/usr/bin/env python
import os
import sys
from basic_utilities import *
from dbsettings import *
from string import *

Buffersize = 250

try:
	None
except:
	print sys.exc_info()[1]
	abort('Failed to import files.\nHas PYTHONPATH been set to ' +
		'include the required python library directory?')

def print_list(l):
	for x in l:
		print x

# Open and return a connection to the database.  If `mode' is 'r', the
# result is a readable file; if `mode' is 'w', the result is a writable file.
# `connectcmd' is executed to connect to the database.
# Precondition: mode == 'r' or mode == 'w'
def connect(connectcmd = dbconnect, mode = 'w'):
	assert(mode == 'r' or mode == 'w')
	try:
		result = os.popen(dbconnect, mode)
	except:
		abort('Encountered problem connecting to database: ',
			sys.exc_info()[1])
	return result

# Disconnect from the database.
def disconnect(connection):
	result = connection.close()
	if result != None:
		print 'Error occurred while disconnecting: ',; print result
	return result

# `l' converted to a string
def list_to_string(l):
	result = ''
	for i in range(0, len(l)):
		result = result + l[i]
	return result

# Insert records into the daily stock table.  'c' is an open database
# connection.  `symbols' is a list of the symbols for the stocks to
# be inserted.  `recordlists' is a list of lists of records, and each
# record is a list.  For symbols[i], recordlists[i] contains the (sub-)
# list of all records to be inserted for symbols[i]; each record is a list
# with the format [date, open, high, low, close, volume].
# Precondition: len(symbols) == len(recordlists)
def insert_daily_stock_records(c, symbols, recordlists):
	assert(len(symbols) == len(recordlists))
	updcmd = []
	for i in range(0, len(symbols)):
		for j in range(0, len(recordlists[i])):
			updcmd.append(daily_stock_insert_cmd(symbols[i], recordlists[i][j]))
	try:
		c.write(list_to_string(updcmd))
	except:
		abort('Encountered problem inserting daily stock data into ' + \
			'database: ', sys.exc_info()[1])
	print "Database insert succeeded."

# Replace the daily stock record ID'd with symbol and date with `record'.
# record is a list: [open, high, low, close, volume]
# If record is empty, the specified record is deleted, but no insertion
# takes place.
# Precondition: len(record) == 5 or len(record) == 0
def replace_daily_stock_record(symbol, date, record):
	assert(len(record) == 5 or len(record) == 0)
	c = connect()
	cmd = daily_stock_delete_cmd(symbol, date) + '\n'
	print 'rep dsr - cmd: ' + cmd
	c.write(cmd)
	if len(record) > 0:
		record = [date] + record
		cmd = daily_stock_insert_cmd(symbol, record) + '\n'
		print 'rep dsr - cmd: ' + cmd
		c.write(cmd)
	disconnect(c)

# Query for all stocks (daily data) with symbol in `symbols' for `date'
# Precondition: len(symbols) > 0 and date != None
def query_for_stock(symbols, date):
	assert(len(symbols) > 0 and date != None)
	dsflds = daily_stock_flds
	result = 'select ' + dsflds[0] + ', ' + dsflds[1] + ', ' + \
		dsflds[2] + ', ' + dsflds[3] + \
		', ' + dsflds[4] + ', ' + dsflds[5] + ', ' + dsflds[6] + \
		' from ' + daily_stock_tbl + ' where ('
	result = result + dsflds[0] + " = '" + symbols[0] + "'"
	for i in range(1, len(symbols)):
		result = result + ' or ' + dsflds[0] + " = '" + symbols[i] + "'"
	result = result + ') and ' + dsflds[1] + ' = ' + str(date) + ';'
	return result


# List `l' (a list of stock records from `stock_records_for_date') formatted
# into a list of two-member tuples, where the first member is the symbol
# and the second is the remainder of the record as a string
def stock_rec_fmt(l):
	result = []
	for s in l:
		x = split(s, ",")
		t = (x[0], join(x[1:], ","))
		result.append(t)
	return result

# Daily stock records for all `symbols' with `date'.
# Symbols is a list and date is of the form yyyymmdd.
# Returns a list with one tuple for each stock specified in `symbols'
# for which there was a record for `date'.  Each tuple has the format:
# (symbol, fields), where fields is a string in the format:
# "date,open,high,low,close,volume\n"
# Precondition: symbols != None and date != none
def stock_records_for_date(symbols, date):
	assert(symbols != None and date != None)
	max_symbols = 3
	result = []
	i = 0
	symblist = []
	for s in symbols:
		symblist.append(lower(s))
		i = i + 1
		if i == max_symbols:
			cmd = query_for_stock(symblist, date)
#			print 'attempting to execute "' + cmd + '"'
			file = db_query(cmd)
			result = result + stock_rec_fmt(file.readlines())
			i = 0
			symblist = []
	if len(symblist) > 0:
		cmd = query_for_stock(symblist, date)
#		print 'attempting to execute "' + cmd + '"'
		file = db_query(cmd)
		result = result + stock_rec_fmt(file.readlines())
	return result

# Insert records into the stock split table.  'c' is an open database
# connection.  `splits' is a list of the stock splits to insert; each
# member of the list is a list that contains the fields for that
# record, with the format [date, symbol, split_value], where date is
# yyyymmdd.
# Precondition: splits != None
def insert_stock_splits(c, splits):
	assert(splits != None)
	updcmd = []
	for s in splits:
		updcmd.append(stock_split_insert_cmd(s))
	try:
#		print_list(updcmd)
		c.write(list_to_string(updcmd))
	except:
		abort('Encountered problem inserting stock split data into ' + \
			'database: ', sys.exc_info()[1])
	print "Database insert succeeded."

# Symbols for all stocks in the MAS database - output to stdout
def mas_symbols():
	file = db_query(symbol_query)
	print list_to_string(file.readlines()),
	result = file.close()
	if result != None:
		print 'Error occurred while disconnecting from database: ',
		print result

def add_watch_entry(e):
	result = "insert into " + watchlist_tbl + " (" + \
		watchlist_symbol_fld + ", " + watchlist_watchflag_fld + \
		") values ('" + e[0] + "', '" + e[1] + "');\n"
	return result

def remove_watch_entry(e):
	result = "delete from " + watchlist_tbl + " where " + \
		watchlist_symbol_fld + " = '" + e[0] + "' and " + \
		watchlist_watchflag_fld + " = '" + e[1] + "';\n"
	return result

# Remove `entries' from the watch list.
# Entries should be a list of tuples, one tuple for each entry in the
# watchlist to be removed.  Each tuple should contain two fields:
# (symbol, watchlist_flag)
def remove_from_watch_list(entries):
	c = connect()
	i = 0
	cmds = []
	for e in entries:
		cmds.append(remove_watch_entry(e))
		i = i + 1
		if i == Buffersize:
			c.write(list_to_string(cmds))
			print 'cmds: ' + list_to_string(cmds)
			cmds = []
			i = 0
	if len(cmds) > 0:
		c.write(list_to_string(cmds))
		print 'cmds: ' + list_to_string(cmds)

	disconnect(c)

# Add `entries' to the watch list.
# Entries should be a list of tuples, one tuple for each entry to be
# inserted into the watchlist.  Each tuple should contain two fields:
# (symbol, watchlist_flag)
def add_to_watch_list(entries):
	c = connect()
	i = 0
	cmds = []
	for e in entries:
		cmds.append(add_watch_entry(e))
		i = i + 1
		if i == Buffersize:
			c.write(list_to_string(cmds))
			print 'cmds: ' + list_to_string(cmds)
			cmds = []
			i = 0
	if len(cmds) > 0:
		c.write(list_to_string(cmds))
		print 'cmds: ' + list_to_string(cmds)

	disconnect(c)
