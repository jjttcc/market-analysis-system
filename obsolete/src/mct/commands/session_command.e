indexing
	description: "External commands associated with a MAS session"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class SESSION_COMMAND inherit

	EXTERNAL_COMMAND
		redefine
			arg_mandatory, execute
		end

	GENERAL_UTILITIES
		export
			{NONE} all
		end

	MCT_CONFIGURATION_PROPERTIES
		export
			{NONE} all
		end

create

	make

feature -- Status report

	arg_mandatory: BOOLEAN is True

feature -- Basic operations

	execute (window: SESSION_WINDOW) is
		local
			env: expanded EXECUTION_ENVIRONMENT
			cmd: STRING
		do
			cmd := clone (command_string)
			replace_tokens (cmd, <<Port_number_specifier>>,
				<<window.port_number>>, Token_start_delimiter,
				Token_end_delimiter)
--print ("(SESSION_COMMAND - " + name + ") Attempting to execute:%N'" +
--cmd + "'%N")
			launch (cmd)
		end

end
