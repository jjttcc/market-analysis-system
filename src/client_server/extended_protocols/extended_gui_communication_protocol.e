indexing

	description:
		"Constants specifying components of the TA server protocol %
		%for servicing GUIs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class EXTENDED_GUI_NETWORK_PROTOCOL inherit

	GUI_NETWORK_PROTOCOL

feature -- Client request IDs

	time_delimited_market_data_request: INTEGER is 12
			-- Time-delimited request for data for a specified tradable

	time_delimited_indicator_data_request: INTEGER is 13
			-- Time-delimited request for indicator data for a
			-- specified tradable

end