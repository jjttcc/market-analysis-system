indexing
	description: "External commands that are not managed as processes"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class UNMANAGED_EXTERNAL_COMMAND inherit

	EXTERNAL_COMMAND

create

	make

feature -- Status report

	arg_mandatory: BOOLEAN is False

feature {NONE} -- Implementation

	do_execute (arg: ANY) is
		local
			env: expanded EXECUTION_ENVIRONMENT
		do
			if debugging_on then
				print ("executing [UEC]: " + command_string + "%N(current " +
				"directory: " + env.current_working_directory + ")%N")
			end
			env.launch (command_string)
		end

end
