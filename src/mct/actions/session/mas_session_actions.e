indexing
	description: "Actions for a MAS session for GUI-event responses"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class MAS_SESSION_ACTIONS inherit

	ACTIONS
		redefine
			owner_window
		end

	TERMINABLE
		export
			{NONE} all
		end

create

	make

feature {NONE} -- Initialization

	make (config: MCT_CONFIGURATION) is
		local
			cmd: SESSION_COMMAND
		do
			create external_commands.make (0)
			create cmd.make (config.Chart_cmd_specifier,
				config.chart_command)
			external_commands.put (cmd, cmd.identifier)
			create cmd.make (config.Start_cl_client_cmd_specifier,
				config.start_command_line_client_command)
			external_commands.put (cmd, cmd.identifier)
			create cmd.make (config.Termination_cmd_specifier,
				config.termination_command)
			external_commands.put (cmd, cmd.identifier)
			configuration := config
			register_for_termination (Current)
		end

feature -- Access

	owner_window: SESSION_WINDOW

feature -- Actions

	start_charting_app is
			-- Start the MAS Charting application
		local
			cmd: COMMAND
		do
			cmd := external_commands @
				configuration.Chart_cmd_specifier
			cmd.execute (owner_window)
		end

	terminate_session is
			-- Terminate an existing MAS "session".
		local
			cmd: COMMAND
		do
			-- NOT port_numbers_in_use.has (owner_window.port_number)
			-- implies that the server has already been terminated.
			if port_numbers_in_use.has (owner_window.port_number) then
				cmd := external_commands @
					configuration.Termination_cmd_specifier
				cmd.execute (owner_window)
				-- Make owner_window.port_number available for other sessions.
				port_numbers_in_use.prune (owner_window.port_number)
			end
		end

	start_command_line is
			-- Start the MAS command-line client.
		local
			cmd: COMMAND
		do
			cmd := external_commands @
				configuration.Start_cl_client_cmd_specifier
			cmd.execute (owner_window)
		end

feature {NONE} -- Implementation - Hook routines

	cleanup is
		do
			if configuration.terminate_sessions_on_exit then
				if not owner_window.is_destroyed then
					terminate_session
				end
			end
		end

end
