indexing
	description: "Parser of command-line arguments for the Installation Tool"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%License to be determined"

class INSTALL_TOOL_COMMAND_LINE inherit

	COMMAND_LINE

	GENERAL_UTILITIES
		export
			{NONE} all
		end

creation

	make

feature {NONE} -- Initialization

	process_remaining_arguments is
		do
			application_dir := ""
			from
				main_setup_procedures.start
			until
				main_setup_procedures.exhausted
			loop
				main_setup_procedures.item.call ([])
				main_setup_procedures.forth
			end
			initialization_complete := True
		end

feature -- Access

	usage: STRING is
			-- Message: how to invoke the program from the command-line
		do
			Result := "Usage: " + command_name + " <application_directory>%N"
		end

feature -- Access -- settings

	application_dir: STRING
			-- Full path of the application directory

feature {NONE} -- Implementation

	set_application_dir is
			-- Set `application_dir' and remove its settings from `contents'.
		do
			from
				contents.start
			until
				not application_dir.is_empty or else contents.exhausted
			loop
				if not contents.item.is_empty then
					application_dir := clone (contents.item)
					contents.remove
				else
					contents.forth
				end
			end
		end

feature {NONE} -- Implementation queries

	main_setup_procedures: LINKED_LIST [PROCEDURE [ANY, TUPLE []]] is
			-- List of the set_... procedures that are called
			-- unconditionally - for convenience
		once
			create Result.make
			Result.extend (agent set_application_dir)
		end

	initialization_complete: BOOLEAN

feature {NONE} -- Implementation - Constants

	Application_dir_error: STRING is
		"Application direcotry was not specified.%N"

invariant

end
