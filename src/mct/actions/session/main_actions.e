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

	CONNECTION_UTILITIES
		export
			{NONE} all
		end

create

	make

feature {NONE} -- Initialization

	post_initialize is
		local
			cmd: MCT_COMMAND
		do
			cmd := configuration.default_start_server_command
			external_commands.put (cmd, cmd.identifier)
		end

feature -- Actions

	connect_to_session is
			-- Connect to an existing MAS "session".
		local
			cmd: SESSION_LOCATION
		do
			create cmd.make (configuration, external_commands)
			cmd.connect_to_session
		end

	terminate_arbitrary_session is
			-- Terminate an arbitrary MAS "session".
		local
			cmd: SESSION_LOCATION
		do
			create cmd.make (configuration, external_commands)
			cmd.terminate_arbitrary_session
		end

	start_server is
			-- Start the MAS server.
		local
			cmd: COMMAND
			portnumber, msg: STRING
			wbldr: expanded WIDGET_BUILDER
			dialog: EV_WIDGET
			session_window: SESSION_WINDOW
			builder: expanded APPLICATION_WINDOW_BUILDER
			orig_cursor: EV_CURSOR
			gtools: expanded GUI_TOOLS
		do
			portnumber := reserved_port_number
			if portnumber = Void then
				dialog := wbldr.new_error_dialog (
					"Port numbers are all in use.", Void)
				dialog.show
			else
				orig_cursor := gtools.set_busy_cursor (owner_window)
				session_window := builder.configured_session_window (
					configuration.hostname, portnumber)
				cmd := external_commands @
					configuration.Start_server_cmd_specifier
				cmd.execute (session_window)
				msg := server_report (
					configuration.server_report_portnumber.to_integer)
				if msg.is_empty then
					session_window.show
				else
					dialog := wbldr.new_error_dialog (msg, Void)
					dialog.show
					port_numbers_in_use.prune (portnumber)
				end
				if
					configuration.start_charts_on_startup
				then
					-- Bypass the normal event-triggered process for
					-- starting the charting application.
					builder.current_mas_session_actions.start_charting_app
				end
				gtools.restore_cursor (owner_window, orig_cursor)
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

	server_report (portnumber: INTEGER): STRING is
			-- A server process's report back on its startup status
		local
			socket: NETWORK_STREAM_SOCKET
			read_cmd: SERVER_REPORT_READER
			failed: BOOLEAN
		do
			if not failed then
				create socket.make_server_by_port (portnumber)
				if socket.socket_ok then
					create read_cmd.make (socket)
					read_cmd.execute (Void)
					if read_cmd.response /= Void then
						Result := read_cmd.response
					else
						Result := Connection_failed
					end
				else
					Result := Connection_failed + ":%N" + socket.error
				end
				if not socket.is_closed then
					socket.close
				end
			else
				Result := Connection_failed
				if socket /= Void and not socket.socket_ok then
					Result := Result + ":%N" + socket.error
				end
			end
		ensure
			result_exists: Result /= Void
		rescue
			if not socket.is_closed then
				socket.close
			end
			failed := True
			retry
		end

	Connection_failed: STRING is "Connection to MAS server failed."

end
