indexing
	description: "Objects that process a target file according to a set of%
		%specifications"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class CLEANUP_COMMAND inherit

	INSTALL_COMMAND

	INSTALLATION_CONSTANTS
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
				create instalL_dir.make (install_dir_name)
				if install_dir.exists then
--print ("Deleting " + install_dir.name + "%N")
					install_dir.recursive_delete
				end
			else
				--!!!Announce the failure.
			end
		rescue
			delete_failed := True
			retry
		end

end
