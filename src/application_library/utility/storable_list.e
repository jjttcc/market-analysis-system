indexing
	description:
		"Abstraction for a persistent LINKED_LIST that is automatically %
		%stored at program termination using the mechanism provided by %
		%parent TERMINABLE"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

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
			not_dirty: not dirty
		end

feature -- Access

	persistent_file_name: STRING
			-- The name of the file that the list contents are stored in.

feature -- Status report

	dirty: BOOLEAN
			-- Does the list need to be saved - that is, has a member of
			-- the list been changed?

feature -- Status setting

	set_dirty is
			-- Set `dirty' to true.
		do
			dirty := true
		ensure
			dirty: dirty
		end

feature -- Utility

cleanup is
--!!! If `dirty': store the object, as not dirty, in file with name
-- `persistent_file_name' in the application directory, if set;
-- if not set, store in the current directory.
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
			dirty := false
			independent_store (outfile)
			outfile.close
		ensure then
			not_dirty: not dirty
		end

	save is
			-- If `dirty': store the object, as not dirty, in file with name
			-- `persistent_file_name' in the application directory, if set;
			-- if not set, store in the current directory.
		local
			app_env: expanded APP_ENVIRONMENT
			outfile: RAW_FILE
		do
			if dirty then
				debug ("persist")
					print("cleanup Storing ");
					print(app_env.file_name_with_app_directory (
						persistent_file_name)); print (".%N")
				end
				create outfile.make_open_write (
					app_env.file_name_with_app_directory (persistent_file_name))
				dirty := false
				independent_store (outfile)
				outfile.close
			end
		ensure then
			not_dirty: not dirty
		end

end -- STORABLE_LIST
