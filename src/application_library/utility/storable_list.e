indexing
	description:
		"Abstraction for a persistent LINKED_LIST that is automatically %
		%stored at program termination using the mechanism provided by %
		%parent TERMINABLE"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class STORABLE_LIST [G] inherit

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

	save is
			-- Store the object in file with name `persistent_file_name' in
			-- the application directory, if it's set; if it's not set,
			-- store in the current directory.
		local
			app_env: expanded APP_ENVIRONMENT
			outfile: RAW_FILE
		do
			debug ("persist")
				print("cleanup Storing ");
				print(app_env.file_name_with_app_directory (
					persistent_file_name)); print (".%N")
			end
			create outfile.make_open_write (
				app_env.file_name_with_app_directory (persistent_file_name))
			independent_store (outfile)
			outfile.close
		end

end -- STORABLE_LIST
