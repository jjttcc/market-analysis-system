indexing
	description: "External commands associated with a MAS session"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class SESSION_COMMAND inherit

	MANAGED_EXTERNAL_COMMAND
		redefine
			execute
		end

	MCT_CONFIGURATION_PROPERTIES
		export
			{NONE} all
		end

create

	make

feature -- Basic operations

	execute (window: SESSION_WINDOW) is
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
		end

end
