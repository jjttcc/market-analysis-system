indexing
	description:
		"Objects that perform an action based on locating an unowned session"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class SESSION_LOCATION inherit

	ACTIONS
		rename
			make as a_make_unused
		export
			{NONE} a_make_unused
		end

	CONNECTION_UTILITIES
		export
			{NONE} all
		end

create

	make

feature {NONE} -- Initialization

	make (conf: MCT_CONFIGURATION;
			ext_cmds: HASH_TABLE [EXTERNAL_COMMAND, STRING]) is
		require
			conf_exists: conf /= Void and ext_cmds /= Void
		do
			configuration := conf
			external_commands := ext_cmds
		ensure
			configuration_set: configuration = conf
			external_commands_set: external_commands = ext_cmds
		end

feature -- Basic operations

	connect_to_session is
			-- Connect to an existing MAS "session".
		local
			window: LOCATE_SESSION_WINDOW
		do
			create window.make
			window.register_client (agent respond_to_connection_request)
			window.show
		end

	terminate_arbitrary_session is
			-- Terminate an arbitrary MAS "session".
		local
			window: LOCATE_SESSION_WINDOW
		do
			create window.make
			window.register_client (agent respond_to_termination_request)
			window.show
		end

feature {NONE} -- Implementation - Callback routines

	respond_to_connection_request (supplier: LOCATE_SESSION_WINDOW) is
		local
			err: STRING
		do
			if supplier.state_changed then
				err := server_connection_diagnosis (supplier.host_name,
					supplier.port_number)
				if
					err = Void
				then
					connect_to_located_session (supplier)
				else
					display_error (err)
				end
			end
		end

	respond_to_termination_request (supplier: LOCATE_SESSION_WINDOW) is
		local
			err: STRING
		do
			if supplier.state_changed then
				err := server_connection_diagnosis (supplier.host_name,
					supplier.port_number)
				if
					err = Void
				then
					terminate_located_session (supplier)
				else
					display_error (err)
				end
			end
		end

feature {NONE} -- Implementation

	connect_to_located_session (supplier: LOCATE_SESSION_WINDOW) is
			-- Connect to the session whose host name and port number are
			-- specified by `supplier'.
		local
			session_window: SESSION_WINDOW
			builder: expanded APPLICATION_WINDOW_BUILDER
		do
			session_window := builder.configured_session_window (
				supplier.host_name, supplier.port_number)
			if not port_numbers_in_use.has (supplier.port_number) then
				port_numbers_in_use.extend (supplier.port_number)
			end
			session_window.show
		end

	terminate_located_session (supplier: LOCATE_SESSION_WINDOW) is
			-- Terminate the session whose host name and port number are
			-- specified by `supplier'.
		local
			session_actions: MAS_SESSION_ACTIONS
		do
			if not port_numbers_in_use.has (supplier.port_number) then
				port_numbers_in_use.extend (supplier.port_number)
			end
			create session_actions.make (configuration)
			session_actions.set_owner_window (supplier)
			session_actions.terminate_session
		end

end
