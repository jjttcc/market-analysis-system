indexing
	description:
		"Abstraction for a persistent LINKED_LIST that is automatically %
		%stored at program termination using the mechanism provided by %
		%parent TERMINABLE"
	status: "Copyright 1998, 1999: Jim Cochrane - see file forum.txt"
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
			-- Store the object in file with name `persistent_file_name' in
			-- the application directory, if set; if not set, store in the
			-- current directory.
		local
			app_env: expanded APP_ENVIRONMENT
		do
			debug ("persist")
				print("cleanup Storing ");
				print(
					app_env.file_name_with_app_directory (persistent_file_name))
				print (".%N")
			end
			store_by_name (
				app_env.file_name_with_app_directory (persistent_file_name))
		end

end -- STORABLE_LIST
