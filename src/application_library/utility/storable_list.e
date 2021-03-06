note
	description:
		"Abstraction for a persistent LINKED_LIST that is automatically %
		%stored at program termination using the mechanism provided by %
		%parent TERMINABLE"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class STORABLE_LIST [G] inherit

	LINKED_LIST [G]
		rename
			make as ll_make
		redefine
			copy, new_chain
		end

	STORABLE
		export {NONE}
			all
		undefine
			copy, is_equal
		end

creation

	make

feature -- Initialization

	make (fname: STRING)
			-- Create the list with `fname' as the `persistent_file_name'.
		require
			not_void: fname /= Void
		do
			persistent_file_name := fname
--!![14.05]!!!!This:
			ll_make
--!!!!!!!!!!was commented out in version 1.7.1 (and perhaps earlier) - Why???!!!
--!!!!!!!!!!after thorough testing, if ll_make appears to cause no
--!!!!!!!!!!problems, remove these comments.
		ensure
			persistent_file_name = fname
		end

feature -- Access

	persistent_file_name: STRING
			-- The name of the file that the list contents are stored in.

feature -- Duplication

	copy (other: like Current)
		do
			Precursor {LINKED_LIST} (other)
			persistent_file_name := other.persistent_file_name.twin
		end

feature -- Utility

	save
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
					persistent_file_name, False)); print (".%N")
			end
			create outfile.make_open_write (
				app_env.file_name_with_app_directory (
				persistent_file_name, False))
			independent_store (outfile)
			outfile.close
		end

feature {NONE} -- Implementation

	new_chain: like Current
			-- A newly created instance of the same type.
			-- This feature may be redefined in descendants so as to
			-- produce an adequately allocated and initialized object.
		do
			create Result.make (persistent_file_name)
		end

end -- STORABLE_LIST
