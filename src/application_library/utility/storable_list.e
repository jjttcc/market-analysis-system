indexing
	description:
		"Abstraction for a persistent array that is automatically %
		%stored at program termination using the mechanism provided by %
		%parents TERMINABLE and STORABLE"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class STORABLE_ARRAY [G] inherit

	TERMINABLE
		export {NONE}
			all
		undefine
			is_equal, copy, consistent, setup
		end

	ARRAY [G]
		rename
			make as arr_make
		end

	STORABLE
		export {NONE}
			all
		undefine
			is_equal, copy, consistent, setup
		end

creation

	make

feature -- Initialization

	make (fname: STRING; minindex, maxindex: INTEGER) is
			-- Create the list with `fname' as the `persistent_file_name'.
		require
			not_void: fname /= Void
		do
			persistent_file_name := fname
			arr_make (minindex, maxindex)
		ensure
			persistent_file_name = fname
		end

feature -- Access

	persistent_file_name: STRING
			-- The name of the file that the list contents are stored in.

feature -- Utility

	cleanup is
		do
			store_by_name (persistent_file_name)
		end

end -- STORABLE_ARRAY
