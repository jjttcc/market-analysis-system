indexing
	description	: "Root class for this application."
	author		: "Generated by the New Vision2 Application Wizard."
	date		: "$Date$"
	revision	: "1.0.0"

class
	APPLICATION

inherit
	EV_APPLICATION

create
	make_and_launch 

feature {NONE} -- Initialization

	make_and_launch is
			-- Initialize and launch application
		do
			default_create
--			prepare
--			launch
			finish_installation
		end

	prepare is
			-- Prepare the first window to be displayed.
			-- Perform one call to first window in order to
			-- avoid to violate the invariant of class EV_APPLICATION.
		do
				-- create and initialize the first window.
			create first_window

				-- Show the first window.
				--| TODO: Remove this line if you don't want the first 
				--|       window to be shown at the start of the program.
			first_window.show
		end

feature {NONE} -- Implementation

	first_window: MAIN_WINDOW
			-- Main window.

	execute_command (cmd: INSTALL_COMMAND) is
			-- Execute all elements in `cmds'.
		require
			cmd_exists: cmd /= Void
		do
--remove:			first_window.set_status (cmd.description)
			cmd.execute (options)
		end

	finish_installation is
			-- Complete the installation.
		local
			cmds: ARRAY [COMMAND]
		do
			cmds := <<create {CONFIGURE_MCT_COMMAND}.make,
				create {CLEANUP_COMMAND}.make>>
			cmds.linear_representation.do_all (agent execute_command)
		end

	options: INSTALL_TOOL_COMMAND_LINE is
		once
			create Result.make
		end
	
end -- class APPLICATION