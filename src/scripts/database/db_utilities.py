# MAS database utilities
#!/usr/bin/env python
import os
import sys
from basic_utilities import *
from dbsettings import *

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
