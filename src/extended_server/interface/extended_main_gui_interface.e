note
	description: "Extended interface to the GUI client"
	author: "Jim Cochrane"
	date: "$Date$";
	note1: "It is expected that, before `execute' is called, the first %
		%character of the input of io_medium has been read."
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class EXTENDED_MAIN_GUI_INTERFACE inherit

	MAIN_GUI_INTERFACE
		redefine
			make_request_handlers
		end

	EXTENDED_GUI_COMMUNICATION_PROTOCOL
		rename
			message_component_separator as message_field_separator
		export
			{NONE} all
		end

creation

	make

feature {NONE} -- Implementation

	make_request_handlers
			-- Create the request handlers.
		local
			cmd: MAS_REQUEST_COMMAND
		do
			Precursor
			create {TIME_DELIMITED_MARKET_DATA_REQUEST_CMD} cmd.make(
					tradable_list_handler)
--!!!!!!!socket-enh - in-progress
cmd.close_connection := True
			request_handlers.extend(cmd, time_delimited_market_data_request)

			create {TIME_DELIMITED_INDICATOR_DATA_REQUEST_CMD} cmd.make(
					tradable_list_handler)
--!!!!!!!socket-enh - in-progress
cmd.close_connection := True
			request_handlers.extend(cmd, time_delimited_indicator_data_request)
		end

end
