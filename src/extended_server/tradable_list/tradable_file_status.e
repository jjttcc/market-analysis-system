indexing
	description: "Status of tradable data files"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%License to be determined"

class TRADABLE_FILE_STATUS inherit

creation

	make

feature -- Initialization

	make (name: STRING; modtime, size: INTEGER) is
		do
			last_modification_time := modtime
			file_size := size
			file_name := name
		ensure
			fields_set: last_modification_time = modtime and
				file_size = size and file_name = name
		end

feature -- Access

	file_name: STRING
			-- The name of the associated file

	last_modification_time: INTEGER
			-- The last recorded modification time of the associated file

	file_size: INTEGER
			-- The last recorded size of the associated file

feature -- Element change

	set_last_modification_time (arg: INTEGER) is
			-- Set `last_modification_time' to `arg'.
		require
			arg_not_negative: arg >= 0
		do
			last_modification_time := arg
		ensure
			last_modification_time_set: last_modification_time = arg
		end

	set_file_size (arg: INTEGER) is
			-- Set `file_size' to `arg'.
		require
			arg_not_negative: arg >= 0
		do
			file_size := arg
		ensure
			file_size_set: file_size = arg
		end

feature {NONE} -- Implementation

invariant

end
