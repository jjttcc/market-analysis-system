indexing
	description: "Objects that process a target file according to a set of%
		%specifications"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class CONFIGURE_MCT_COMMAND inherit

	INSTALL_COMMAND

create

    make

feature {NONE} -- Initialization

	make is
        do
        end

feature -- Access

	description: STRING is "Configuring"

feature -- Status report

	arg_mandatory: BOOLEAN is True

feature -- Basic operations

	execute (options: INSTALL_TOOL_COMMAND_LINE) is
		local
		do
		end

end
