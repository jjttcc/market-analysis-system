indexing
	description: "Parser of command-line arguments for the Configuration Tool"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%License to be determined"

class CONFIG_TOOL_COMMAND_LINE inherit

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
			Result := "Usage: " + command_name + " [options]" +
				"%NOptions:%N" +
				"   -cmdfile <file>   Obtain instructions from <file> %N" +
				"   -file <target>    Operate on the file with paht %
					%<target>%N" +
				"   -h                Print this help message%N"
		end

feature -- Access -- settings

	command_file: STRING
			-- Path of the file from which instructions (commands) will be read

	target_file: STRING
			-- Path of the file to be modified

	incaseneeded: PLAIN_TEXT_FILE
			-- The input file when `input_from_file'

feature {NONE} -- Implementation - Hook routine implementations

feature {NONE} -- Implementation

	set_command_file is
			-- Set `command_file' and remove its settings from `contents'.
		do
			if option_in_contents ('c') then
				if contents.item.count > 2 then
					create command_file.make (contents.item.count - 2)
					command_file.append (contents.item.substring (
						3, contents.item.count))
					contents.remove
				else
					contents.remove
					if not contents.exhausted then
						create command_file.make (contents.item.count)
						command_file.append (contents.item)
						contents.remove
					else
						error_occurred := True
						log_errors (<<Command_file_error>>)
					end
				end
			end
		end

	set_target_file is
			-- Set `target_file' and remove its settings from `contents'.
		do
			if option_in_contents ('f') then
				if contents.item.count > 2 then
					create target_file.make (contents.item.count - 2)
					target_file.append (contents.item.substring (
						3, contents.item.count))
					contents.remove
				else
					contents.remove
					if not contents.exhausted then
						create target_file.make (contents.item.count)
						target_file.append (contents.item)
						contents.remove
					else
						error_occurred := True
						log_errors (<<Command_file_error>>)
					end
				end
			end
		end

feature {NONE} -- Implementation queries

	main_setup_procedures: LINKED_LIST [PROCEDURE [ANY, TUPLE []]] is
			-- List of the set_... procedures that are called
			-- unconditionally - for convenience
		once
			create Result.make
			Result.extend (agent set_command_file)
			Result.extend (agent set_target_file)
		end

	initialization_complete: BOOLEAN

feature {NONE} -- Implementation - Constants

	Command_file_error: STRING is
		"File path for -cmdfile option was not specified.%N"

	Target_file_error: STRING is
		"File path for -file option was not specified.%N"

invariant

end
