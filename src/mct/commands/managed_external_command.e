indexing
	description: "External commands that are managed as processes"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2004: Jim Cochrane - %
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

	MCT_CONFIGURATION_PROPERTIES
		export
			{NONE} all
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

feature {NONE} -- Implementation

	do_execute (window: SESSION_WINDOW) is
		local
			args: ARRAY [STRING]
		do
			if program = Void then
				process_components
			end
			args := deep_clone (arguments)
			-- Work with a deep-clone of `arguments' to prevent side-effects:
			-- `arguments' needs to keep its original "tokens", which are
			-- replaced here dynamically in the cloned array to "configure" the
			-- arguments for the `launch' call with the current settings
			-- (e.g., window.port_number).
			args.linear_representation.do_all (agent replace_tokens (?,
				<<Port_number_specifier, Hostname_specifier>>,
				<<window.port_number, window.host_name>>,
				Token_start_delimiter, Token_end_delimiter))
			launch (program, args, window)
		ensure then
			process_managed: has_process (window.host_name,
				window.port_number)
		end

	launch (prog: STRING; args: ARRAY [STRING]; window: SESSION_WINDOW) is
			-- "Launch" the command.
		require
			args_exist: prog /= Void and args /= Void and window /= Void
		local
			env: expanded EXECUTION_ENVIRONMENT
		do
			if debugging_on then
				print ("executing [MEC]: " + program + " " +
					field_concatenation (args.linear_representation, " ") +
					"%N(current directory: " +
					env.current_working_directory + ")%N")
			end
			create last_process.make_capture_output (prog, args)
			add_process (last_process, window.host_name, window.port_number)
			last_process.execute
		ensure
			process_managed: has_process (window.host_name, window.port_number)
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
