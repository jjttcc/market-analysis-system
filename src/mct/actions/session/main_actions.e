indexing
	description: "Main MAS Control Terminal actions for GUI-event responses"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class MAIN_ACTIONS inherit

	ACTIONS
		redefine
			post_initialize
		end

create

	make

feature {NONE} -- Initialization

	post_initialize is
		local
			cmd: EXTERNAL_COMMAND
		do
			cmd := configuration.default_start_server_command
			external_commands.put (cmd, cmd.identifier)
		end

feature -- Actions

	connect_to_session is
			-- Connect to an existing MAS "session".
		local
			cmd: SESSION_LOCATON
		do
			create cmd.make (configuration, external_commands)
			cmd.connect_to_session
		end

	terminate_arbitrary_session is
			-- Terminate an arbitrary MAS "session".
		local
			cmd: SESSION_LOCATON
		do
			create cmd.make (configuration, external_commands)
			cmd.terminate_arbitrary_session
		end

	start_server is
			-- Start the MAS server.
		local
			cmd: COMMAND
			portnumber: STRING
			wbldr: expanded WIDGET_BUILDER
			dialog: EV_WIDGET
			session_window: SESSION_WINDOW
			builder: expanded APPLICATION_WINDOW_BUILDER
		do
			portnumber := reserved_port_number
			if portnumber = Void then
				dialog := wbldr.new_error_dialog (
					"Port numbers are all in use.")
				dialog.show
			else
				session_window := builder.configured_session_window (
					configuration.hostname, portnumber)
				cmd := external_commands @
					configuration.Start_server_cmd_specifier
				cmd.execute (session_window)
			end
		end

	configure_server_startup is
		local
			server_selection: START_SERVER_SELECTION
		do
			create server_selection.make (configuration, external_commands)
			server_selection.execute
		end

	edit_preferences is
			-- Edit "Preferences".
		do
			print ("Stub!!! - Edit preferences%N")
		end

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
