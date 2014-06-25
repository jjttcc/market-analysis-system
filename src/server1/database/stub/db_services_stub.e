note
	description: "MAS database services - Stub implmentation for releases %
		%without database functionality"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class DB_SERVICES_STUB inherit

	MAS_DB_SERVICES

creation

	make

feature -- Initialization

	make do end

feature -- Access

	stock_splits: ODBC_STOCK_SPLITS

	daily_stock_data (symbol: STRING): DB_INPUT_SEQUENCE
		do
		end

	intraday_stock_data (symbol: STRING): DB_INPUT_SEQUENCE
		do
		end

	daily_derivative_data (symbol: STRING): DB_INPUT_SEQUENCE
		do
		end

	intraday_derivative_data (symbol: STRING): DB_INPUT_SEQUENCE
		do
		end

	single_string_query_result (query: STRING): STRING
		do
		end

	stock_data: STOCK_DATA
		do
		end

	derivative_data: TRADABLE_DATA
		do
		end

feature -- Status report

	connected: BOOLEAN
			-- Are we connected to the database?
		do
		end

feature -- Basic operations

	connect
			-- Connect to the database.
		do
			last_error :=
				"Database services are not available in this release."
			fatal_error := True
		end

	disconnect
			-- Disconnect from database.
		do
		end

feature {NONE} -- Implementation

	list_from_query (q: STRING): LIST [STRING]
			-- List of STRING from query `q' with 1-column result
		do
		end

end -- class DB_SERVICES_STUB
