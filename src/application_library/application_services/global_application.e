indexing
	description: "Global entities needed by the application"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class

	GLOBAL_APPLICATION

feature {NONE} -- Utility

	current_date: DATE is
		do
			!!Result.make_now
		end

	current_time: TIME is
		do
			!!Result.make_now
		end

feature {NONE} -- Constants

	default_input_file_name: STRING is "/tmp/tatest"

	Dir_separator: CHARACTER is '/'

end -- GLOBAL_APPLICATION
