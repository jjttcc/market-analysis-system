indexing
	description: "External commands that are managed as processes"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class MANAGED_EXTERNAL_COMMAND inherit

	EXTERNAL_COMMAND

	GENERAL_UTILITIES
		export
			{NONE} all
		end

	GLOBAL_APPLICATION_FACILITIES
		export
			{NONE} all
			{ANY} has_process
		end

create

	make

feature -- Access

	program: STRING
			-- The name of the program to execute

	arguments: ARRAY [STRING]
			-- The arguments to pass to `program'

	last_process: EPX_EXEC_PROCESS
			-- The last process executed by `execute'

	session_window: SESSION_WINDOW
			-- Session window, if any, used in last call to `execute'

feature -- Status report

	arg_mandatory: BOOLEAN is True

feature -- Basic operations

	execute (window: SESSION_WINDOW) is
		do
			if program = Void then
				process_components
			end
			launch (program, arguments, window)
		ensure
			process_managed: has_process (window.host_name,
				window.port_number)
		end

feature {NONE} -- Implementation

	launch (prog: STRING; args: ARRAY [STRING]; window: SESSION_WINDOW) is
			-- "Launch" the command.
		require
			args_exist: prog /= Void and args /= Void and window /= Void
		local
			env: expanded EXECUTION_ENVIRONMENT
			previous_directory: STRING
			gu: expanded GENERAL_UTILITIES
		do
			if working_directory /= Void then
				previous_directory := env.current_working_directory
				env.change_working_directory (working_directory)
			end
			if debugging_on then
				print ("executing: " + program + " " + field_concatenation (
					args.linear_representation, " ") + "%N")
			end
			create last_process.make_capture_output (prog, args)
			add_process (last_process, window.host_name, window.port_number)
			last_process.execute
			if working_directory /= Void then
				env.change_working_directory (previous_directory)
			end
		ensure
			process_managed:
				has_process (window.host_name,
				window.port_number)
		end

	process_components is
		local
			cmd_components: ARRAY [STRING]
			regutil: expanded REGULAR_EXPRESSION_UTILITIES
		do
			cmd_components := regutil.split (" +", command_string)
			if cmd_components.is_empty then
				-- Report empty command error.
			else
				program := cmd_components @ 1
				arguments := cmd_components.subarray (2, cmd_components.upper)
			end
		end

invariant

end
