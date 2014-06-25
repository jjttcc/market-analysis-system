note
	description: "External commands that are not managed as processes"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class UNMANAGED_EXTERNAL_COMMAND inherit

	EXTERNAL_COMMAND

create

	make

feature -- Status report

	arg_mandatory: BOOLEAN = False

feature {NONE} -- Implementation

	do_execute (arg: ANY)
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
