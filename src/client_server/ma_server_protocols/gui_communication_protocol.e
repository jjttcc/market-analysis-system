indexing

	description:
		"Constants specifying components of the TA server protocol %
		%for servicing GUIs"
	status: "See notice at end of class";
	date: "$Date$";
	revision: "$Revision$"

class GUI_SERVER_PROTOCOL inherit

	SERVER_PROTOCOL

feature -- Access

	Market_data_request: INTEGER is 1
	Error: INTEGER is 2

end -- class GUI_SERVER_PROTOCOL
