indexing
	description: "External commands to be delegated to the operating system"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class EXTERNAL_COMMAND inherit

	MCT_COMMAND

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
			-- The actual command to be delegated to the OS

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
		do
--print ("(EXTCMD - " + name + ") Attempting to execute:%N'" +
--command_string + "'%N")
			launch (command_string)
		end

	launch (cmd: STRING) is
			-- "Launch" the command.
		local
			env: expanded EXECUTION_ENVIRONMENT
			previous_directory: STRING
		do
			if working_directory /= Void then
				previous_directory := env.current_working_directory
				env.change_working_directory (working_directory)
			end
			env.launch (cmd)
			if working_directory /= Void then
				env.change_working_directory (previous_directory)
			end
		end

end
