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
			args: ARRAY [STRING]
		do
			args := deep_clone (arguments)
			args.linear_representation.do_all (agent replace_tokens (?,
				<<Port_number_specifier, Hostname_specifier>>,
				<<window.port_number, window.host_name>>,
				Token_start_delimiter, Token_end_delimiter))
			launch (program, args)
		end

end
