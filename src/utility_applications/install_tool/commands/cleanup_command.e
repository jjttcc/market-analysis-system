indexing
	description: "Objects that process a target file according to a set of%
		%specifications"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2004: Jim Cochrane - %
		%License to be determined"

class CLEANUP_COMMAND inherit

	INSTALL_COMMAND

	INSTALLATION_FACILITIES
		export
			{NONE} all
		end

create

    make

feature {NONE} -- Initialization

	make is
        do
        end

feature -- Access

	description: STRING is "Cleaning up"

feature -- Status report

	arg_mandatory: BOOLEAN is True

feature -- Basic operations

	execute (options: INSTALL_TOOL_COMMAND_LINE) is
		local
			install_dir: DIRECTORY
			delete_failed: BOOLEAN
		do
			if not delete_failed then
				if is_nt then
					-- Let the "cleanup" script know that this is an "NT"
					-- system (so that it can, for example, delete itself):
					(create {PLAIN_TEXT_FILE}.make_open_write (
						NT_file_name)).close
				end
				create instalL_dir.make (install_dir_name)
				if install_dir.exists then
					install_dir.recursive_delete
				end
			else
				-- Let the "cleanup" script take care of the cleanup.
			end
		rescue
			delete_failed := True
			retry
		end

feature {NONE} -- Implementation

	NT_file_name: STRING is "os_is_nt"

end
