indexing
	description:
		"Abstraction for a persistent LINKED_LIST that is automatically %
		%stored at program termination using the mechanism provided by %
		%parent TERMINABLE"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class STORABLE_LIST [G] inherit

	TERMINABLE
		export {NONE}
			all
		end

	LINKED_LIST [G]
		rename
			make as ll_make
		end

	STORABLE
		export {NONE}
			all
		end

creation

	make

feature -- Initialization

	make (fname: STRING) is
			-- Create the list with `fname' as the `persistent_file_name'.
		require
			not_void: fname /= Void
		do
			persistent_file_name := fname
			ll_make
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

end -- STORABLE_LIST
