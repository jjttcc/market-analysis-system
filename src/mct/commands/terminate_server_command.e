indexing
	description: "MCT_COMMAND to terminate the server process"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class TERMINATE_SERVER_COMMAND inherit

	SESSION_COMMAND
		rename
			make as sc_make_unused
		redefine
			execute
		end

create

	make

feature -- Initialization

	make (id: STRING) is
		require
			id_exists: id /= Void
			id_not_empty: not id.is_empty
		do
			identifier := id
		ensure
			items_set: identifier = id
		end

feature -- Basic operations

	execute (window: SESSION_WINDOW) is
		local
			connection: CONNECTION
		do
			create connection.start_conversation (
				window.host_name, window.port_number.to_integer)
			connection.send_termination_request (False)
		end

end
