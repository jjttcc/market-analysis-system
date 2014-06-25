note

	description:
		"Constants specifying components of the TA server protocol %
		%for servicing GUIs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class EXTENDED_GUI_COMMUNICATION_PROTOCOL inherit

	GUI_COMMUNICATION_PROTOCOL

feature -- Client request IDs

	time_delimited_market_data_request: INTEGER = 12
			-- Time-delimited request for data for a specified tradable

	time_delimited_indicator_data_request: INTEGER = 13
			-- Time-delimited request for indicator data for a
			-- specified tradable

end
