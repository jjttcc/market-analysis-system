indexing
	description: "External commands to be delegated to the operating system"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

deferred class EXTERNAL_COMMAND inherit

	MCT_COMMAND

	GENERAL_UTILITIES
		export
			{NONE} all
		end

	GLOBAL_APPLICATION_FACILITIES
		export
			{NONE} all
			{ANY} has_process
		end

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

	working_directory: STRING
			-- Directory in which the command is to be executed

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

	execute (arg: ANY) is
		local
			env: expanded EXECUTION_ENVIRONMENT
			previous_directory: STRING
		do
			if working_directory /= Void then
				previous_directory := env.current_working_directory
				env.change_working_directory (working_directory)
			end
			do_execute (arg)
			if working_directory /= Void then
				if debugging_on then
					print ("'working_directory': " + working_directory + "%N" +
					"Changing back to prev dir: " + previous_directory+ "%N")
				end
				env.change_working_directory (previous_directory)
			end
		end

feature {NONE} -- Implementation

	do_execute (arg: ANY) is
		deferred
		end

invariant

end
