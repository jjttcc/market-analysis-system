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
		do
			create instalL_dir.make (install_dir_name)
			if install_dir.exists then
				install_dir.delete_content
			end
		end

end
