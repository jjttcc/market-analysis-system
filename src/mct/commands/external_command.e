indexing
	description: "External commands to be delegated to the operating system"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class EXTERNAL_COMMAND inherit

	COMMAND

create

	make

feature {NONE} -- Initialization

	make (id: STRING; cmd: STRING) is
		require
			args_exist: id /= Void and cmd /= Void
		do
			identifier := id
			command_string := cmd
		ensure
			items_set: identifier = id and command_string = cmd
		end

feature -- Access

	identifier: STRING
			-- String that uniquely identifies the command

	command_string: STRING
			-- The actual command to be delegated to the OS

feature -- Status report

	arg_mandatory: BOOLEAN is
		once
			Result := False
		end

feature -- Basic operations

	execute (arg: ANY) is
		local
			env: expanded EXECUTION_ENVIRONMENT
		do
--!!!print ("Attempting to execute '" + command_string + "'%N")
			env.launch (command_string)
		end

end
