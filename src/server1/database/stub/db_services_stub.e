indexing
	description: "MAS database services - Stub implmentation for releases %
		%without database functionality"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class DB_SERVICES_STUB inherit

	MAS_DB_SERVICES

creation

	make

feature -- Initialization

	make is do end

feature -- Access

	stock_splits: ODBC_STOCK_SPLITS

	daily_stock_data (symbol: STRING): DB_INPUT_SEQUENCE is
		do
		end

	intraday_stock_data (symbol: STRING): DB_INPUT_SEQUENCE is
		do
		end

	daily_derivative_data (symbol: STRING): DB_INPUT_SEQUENCE is
		do
		end

	intraday_derivative_data (symbol: STRING): DB_INPUT_SEQUENCE is
		do
		end

	single_string_query_result (query: STRING): STRING is
		do
		end

	stock_data: STOCK_DATA is
		do
		end

	derivative_data: TRADABLE_DATA is
		do
		end

feature -- Status report

	connected: BOOLEAN is
			-- Are we connected to the database?
		do
		end

feature -- Basic operations

	connect is
			-- Connect to the database.
		do
			last_error :=
				"Database services are not available in this release."
			fatal_error := true
		end

	disconnect is
			-- Disconnect from database.
		do
		end

feature {NONE} -- Implementation

	list_from_query (q: STRING): LIST [STRING] is
			-- List of STRING from query `q' with 1-column result
		do
		end

end -- class DB_SERVICES_STUB
