indexing
	description: "Main MCT actions for GUI-event responses"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class MAIN_ACTIONS inherit

	ACTIONS

create

	make

feature {NONE} -- Initialization

	make (config: MCT_CONFIGURATION) is
		local
			cmd: EXTERNAL_COMMAND
		do
			create external_commands.make (0)
			create {SESSION_COMMAND} cmd.make (
				config.Start_server_cmd_specifier, config.start_server_command)
			external_commands.put (cmd, cmd.identifier)
			create cmd.make (config.Termination_cmd_specifier,
				config.termination_command)
			external_commands.put (cmd, cmd.identifier)
			configuration := config
		end

feature -- Actions

	connect_to_session is
			-- Connect to an existing MAS "session".
		do
			print ("Connect to MAS session Stub!!!%N")
		end

	terminate_arbitrary_session is
			-- Terminate an arbitrary MAS "session".
		local
			cmd: COMMAND
		do
			-- Need to obtain the session's port number from the user.
			--cmd.execute (owner_window)
			print ("Terminate an arbitrary MAS session Stub!!!%N")
		end

	start_server is
			-- Start the MAS server.
		local
			cmd: COMMAND
			portnumber: STRING
			wbldr: expanded WIDGET_BUILDER
			dialog: EV_WIDGET
			builder: APPLICATION_WINDOW_BUILDER
			session_window: SESSION_WINDOW
		do
			create builder
			portnumber := reserved_port_number
			if portnumber = Void then
				dialog := wbldr.new_error_dialog (
					"Port numbers are all in use.")
				dialog.show
			else
				session_window := builder.mas_session_window
				session_window.set_port_number (portnumber)
				cmd := external_commands @
					configuration.Start_server_cmd_specifier
				cmd.execute (session_window)
				server_is_running := True
			end
		end

	configure_server_startup is
			-- Configure how the server is to be started up.
		local
			cmd: COMMAND
		do
			print ("Configure server startup Stub!!!%N")
		end

feature {NONE} -- Implementation - Status report

	server_is_running: BOOLEAN
			-- Is the MAS server currently running?

feature {NONE} -- Implementation

	reserved_port_number: STRING is
		local
			pnums: LIST [STRING]
		do
			from
				pnums := configuration.valid_portnumbers
				pnums.start
			until
				Result /= Void or pnums.exhausted
			loop
				if not port_numbers_in_use.has (pnums.item) then
					Result := pnums.item
					port_numbers_in_use.extend (pnums.item)
				end
				pnums.forth
			end
		end

end
