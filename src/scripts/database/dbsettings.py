import sys
import os

try:
	from basic_utilities import *
except:
	print sys.exc_info()[1]
	print 'Failed to import basic_utilities file.\nHas PYTHONPATH been ' +\
		'set to include the required python library directory?'

# Command to connect to the database
dbconnect = '/usr/bin/psql -q mas'
# Command to obtain the symbol list from the database
symbol_query = "select symbol from stock_information order by symbol;"
# String used to execute a one-shot command to the database
one_shot_cmd = "/usr/bin/psql -t -q -F , -A mas -c "

# Name of daily stock table
daily_stock_tbl = 'daily_stock_data'
# daily stock table field names
daily_stock_flds = ['symbol', 'date', 'open_price', 'high_price', 'low_price',
	'close_price', 'volume']
# Name of watchlist table
watchlist_tbl = 'watch_list'
watchlist_symbol_fld = 'symbol'
watchlist_watchflag_fld = 'category'

# Name of stock split table
stock_split_tbl = 'stock_split'
# stock split table field names
stock_split_flds = ['date', 'symbol', 'value']

# In one shot, send `s' as a query to the database and return a readable
# popened file as the result.
def db_query(s):
	query = one_shot_cmd + '"' + s + '"'
	try:
		result = os.popen(query, 'r')
	except:
		abort('Encountered problem connecting to database: ',
			sys.exc_info()[1])
	return result

def daily_insert_portion(symbol, values):
	result = ' ('
	for i in range(0, len(daily_stock_flds) - 1):
		result = result + daily_stock_flds[i] + ', '
	result = result + daily_stock_flds[len(daily_stock_flds) - 1] + ') '
	result = result + " values ('" + symbol + "', "
	for i in range(0, len(values) - 1):
		result = result + str(values[i]) + ', '
	result = result + str(values[len(values) - 1]) + ') '
	return result

# Command to insert `values' into the database for stock (with daily data)
# with symbol `symbol', where values is a list: [date, open, high, low,
# close, volume], where date is an integer; open, high, low, close are
# floats, and volume is a float or an integer.
def daily_stock_insert_cmd(symbol, values):
	assert(len(values) >= 6)
	result = 'insert into ' + daily_stock_tbl + \
		daily_insert_portion(symbol, values) + ";\n"
	return result

# Command to delete a record from the database for stock (with daily data)
# with symbol `symbol', and date `date'.
def daily_stock_delete_cmd(symbol, date):
	symbolfld = daily_stock_flds[0]
	datefld = daily_stock_flds[1]
	result = "delete from " + daily_stock_tbl + " where " + symbolfld + \
		" = '" + symbol + "' and " + datefld + " = " + str(date) + ";"
	return result

# Command to insert stock split into the database, where `split' is a
# list whose members are [date, symbol, split_value] and date is
# formatted: yyyymmdd.
def stock_split_insert_cmd(split):
	assert(len(split) == 3)
	result = "insert into " + stock_split_tbl + " (" + stock_split_flds[0] + \
		", " + stock_split_flds[1] + ", " + stock_split_flds[2] + \
		") values (" + split[0] + ", '" + split[1] + "', " + split[2] + ");\n"
	return result
