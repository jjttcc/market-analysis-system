indexing
	description: "Interface to the GUI client"
	author: "Jim Cochrane"
	date: "$Date$";
	note: "It is expected that, before `execute' is called, the first %
		%character of the input of io_medium has been read."
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class EXTENDED_MAIN_GUI_INTERFACE inherit

	MAIN_GUI_INTERFACE
		redefine
			make_request_handlers
		end

	EXTENDED_GUI_NETWORK_PROTOCOL
		export
			{NONE} all
		end

creation

	make

feature {NONE} -- Implementation

	make_request_handlers is
			-- Create the request handlers.
		do
			Precursor
			request_handlers.extend (create {
				TIME_DELIMITED_MARKET_DATA_REQUEST_CMD}.make (
					tradable_list_handler), time_delimited_market_data_request)
			request_handlers.extend (create {
				TIME_DELIMITED_INDICATOR_DATA_REQUEST_CMD}.make (
					tradable_list_handler),
					time_delimited_indicator_data_request)
		end

end
