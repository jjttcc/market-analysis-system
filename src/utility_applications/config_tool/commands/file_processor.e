indexing
	description: "Objects that process a target file according to a set of%
		%specifications"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class FILE_PROCESSOR inherit

	COMMAND

	REGULAR_EXPRESSION_UTILITIES
		export
			{NONE} all
		end

	ERROR_PUBLISHER
		export
			{ERROR_SUBSCRIBER} all
		end

create

    make

feature {NONE} -- Initialization

	make is
        do
        end

feature -- Access

	target_file: PLAIN_TEXT_FILE
			-- Target file to be modified

	target_file_contents: STRING
			-- Contents of the target file

feature -- Status report

	arg_mandatory: BOOLEAN is True

feature -- Basic operations

	execute (options: CONFIG_TOOL_COMMAND_LINE) is
		local
			configuration: CONFIGURATION
			reader: FILE_READER
		do
			create configuration.make (options.command_file_path)
			make_target_file (options.target_file_path)
			create reader.make (target_file.name)
			replacement_specs :=
				configuration.replacement_specifications
			target_file_contents := reader.contents
			replacement_specs.current_keys.linear_representation.do_all (
				agent do_replacement)
			target_file.open_write
			target_file.put_string (target_file_contents)
		end

feature {NONE} -- Implementation

	make_target_file (path: STRING) is
		do
			create target_file.make (path)
			if not target_file.exists then
				publish_error ("Cannot open target file: " + path + "%N")
			end
		end

	do_replacement (key: STRING) is
		do
			target_file_contents := gsub (
				key, replacement_specs @ key, target_file_contents)
		end

	replacement_specs: HASH_TABLE [STRING, STRING]
			-- Specification of a set of replacements to be carried out
			-- on the target file, where the hash-table key is a regular
			-- expression specifying what substrings of the target file
			-- contents are to be replaced (the substrings that match
			-- the pattern specified by the key) and the hash-table value
			-- specifies the value with which each matched substring is
			-- to be replaced

end
