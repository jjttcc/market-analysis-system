indexing

	description:
		"Constants specifying components of the TA server protocol %
		%for servicing GUIs"
	status: "See notice at end of class";
	date: "$Date$";
	revision: "$Revision$"

class GUI_NETWORK_PROTOCOL inherit

	NETWORK_PROTOCOL

feature -- Client request IDs

	Market_data_request: INTEGER is 1
	Indicator_data_request: INTEGER is 2
	Market_list_request: INTEGER is 3
	Indicator_list_request: INTEGER is 4

feature -- Server response IDs

	Error: INTEGER is 5
	OK: INTEGER is 6

end -- class GUI_NETWORK_PROTOCOL
