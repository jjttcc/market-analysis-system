indexing
	description: "External commands to be delegated to the operating system"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class EXTERNAL_COMMAND inherit

	MCT_COMMAND
		redefine
			arg_mandatory
		end

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

feature {NONE} -- Initialization

	make (id: STRING; cmd: STRING) is
		require
			args_exist: id /= Void and cmd /= Void
			id_not_empty: not id.is_empty
		do
			identifier := id
			command_string := cmd
		ensure
			items_set: identifier = id and command_string = cmd
		end

feature -- Access

	command_string: STRING
			-- The complete command, with arguments, to be delegated to the OS

	contents: STRING is
		do
			Result := command_string
		end

	program: STRING
			-- The name of the program to execute

	arguments: ARRAY [STRING]
			-- The arguments to pass to `program'

	working_directory: STRING
			-- Directory in which the command is to be executed

	last_process: EPX_EXEC_PROCESS
			-- The last process executed by `execute'

	session_window: SESSION_WINDOW
			-- Session window, if any, used in last call to `execute'

feature -- Status report

	arg_mandatory: BOOLEAN is True

feature -- Element change

	set_working_directory (arg: STRING) is
			-- Set `working_directory' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			working_directory := arg
		ensure
			working_directory_set: working_directory = arg and
				working_directory /= Void
		end

feature -- Basic operations

	execute (window: EV_WINDOW) is
		do
			session_window ?= window
			if program = Void then
				process_components
			end
			launch (program, arguments, session_window)
		ensure
			process_managed_if_session_window: (session_window /= Void) implies
				has_process (session_window.host_name,
				session_window.port_number)
		end

feature {NONE} -- Implementation

	launch (prog: STRING; args: ARRAY [STRING]; window: SESSION_WINDOW) is
			-- "Launch" the command.
		local
			env: expanded EXECUTION_ENVIRONMENT
			previous_directory: STRING
			gu: expanded GENERAL_UTILITIES
		do
			if working_directory /= Void then
				previous_directory := env.current_working_directory
				env.change_working_directory (working_directory)
			end
			debug
				print ("Executing:%N" + prog + "%N")
				gu.print_list (args); print ("%N")
			end
			create last_process.make_capture_output (prog, args)
			if session_window /= Void then
				add_process (last_process, window.host_name, window.port_number)
			end
			if debugging_on then
				print ("executing: " + program + " " + field_concatenation (
					args.linear_representation, " ") + "%N")
			end
			last_process.execute
			if working_directory /= Void then
				env.change_working_directory (previous_directory)
			end
		ensure
			process_managed_if_session_window: session_window /= Void implies
				has_process (session_window.host_name,
				session_window.port_number)
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
