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

	mctrc_contents: STRING
			-- Contents to be placed into the official mctrc file
			
feature -- Access -- settings

	application_dir: STRING
			-- Full path of the application directory

feature -- Element change

	set_mctrc_contents (arg: STRING) is
			-- Set `mctrc_contents' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			mctrc_contents := arg
		ensure
			mctrc_contents_set: mctrc_contents = arg and mctrc_contents /= Void
		end

feature {NONE} -- Implementation

	set_application_dir is
			-- Set `application_dir' and remove its settings from `contents'.
		do
			from
				application_dir := ""
				contents.start
				if not contents.item.is_empty then
					application_dir := contents.item
					contents.remove
				else
					contents.forth
				end
			until
				contents.exhausted
			loop
				-- Assume that if there are two or more arguments, the
				-- cause is a path with spaces being passed as an argument
				-- and try to duplicate the original path.
				if not contents.item.is_empty then
					application_dir := application_dir + " " + contents.item
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
