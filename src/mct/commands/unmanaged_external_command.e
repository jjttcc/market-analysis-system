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
			if debugging_on then
				print ("executing: " + command_string + "%N")
			end
			env.launch (command_string)
			if working_directory /= Void then
				env.change_working_directory (previous_directory)
			end
		end

end
