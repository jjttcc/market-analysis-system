note

	description:
		"Constants specifying components of the 'data-supplier' server %
		%communication protocol"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class DATA_SUPPLIER_COMMUNICATION_PROTOCOL inherit

	BASIC_COMMUNICATION_PROTOCOL

feature -- Client components - request IDs, etc.

	symbol_list_request: INTEGER = 1
			-- Request for a list symbols for all available tradables

	tradable_data_request: INTEGER = 2
			-- Request for data for a specified tradable

	daily_avail_req: INTEGER = 3
			-- Request for whether daily data is available

	intra_avail_req: INTEGER = 4
			-- Request for whether intra-day data is available

	intraday_data_flag: STRING = "i"
			-- Flag indicating that indicator data is being requested

	client_request_terminator: STRING = "%N"
			-- Character indicating end of client request

feature -- Server response IDs

	ok: INTEGER = 101
			-- Response indicating that no errors occurred

	error: INTEGER = 102
			-- Response indicating that there was a problem receiving or
			-- parsing the client request

--!!!???:
	invalid_symbol: INTEGER = 103
			-- Response indicating that the server requested data for
			-- a symbol that is not in the database

--!!!???:
	warning: INTEGER = 104
			-- Response indicating that a non-fatal error occurred

feature -- Server response values

	true_response: CHARACTER = 'T'

	false_response: CHARACTER = 'F'

feature -- Error messages

	invalid_server_response: STRING = "Invalid server response"

	empty_server_response: STRING = "Server response is empty"

end
