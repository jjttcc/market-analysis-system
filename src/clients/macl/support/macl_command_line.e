indexing
	description: "Parser of command-line arguments for Market Analysis %
		%Command-Line client application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MACL_COMMAND_LINE inherit

	COMMAND_LINE
		rename
			make as cl_make
		export
			{NONE} cl_make
		redefine
			help_character
		end

	GENERAL_UTILITIES
		export
			{NONE} all
		end

	ERROR_SUBSCRIBER --!!!??

creation

	make

feature {NONE} -- Initialization

	make is
		do
			port_number := -1
			host_name := ""
			cl_make
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
			Result := "Usage: " + command_name + " [options] port_number" +
				"%NOptions:%N" +
				"   -h <hostname>   Connect to server on host <hostname>%N" +
				"   -r <file>       Record user input and save to <file>%N" +
				"   -i <file>       Obtain input from <file> instead of %N" +
				"   -?              Print this help message%N" +
				"the console%N"
		end

feature -- Access -- settings

	host_name: STRING
			-- host name of the machine on which the server is running

	port_number: INTEGER
			-- Port number of the server socket connection: -1 if not set

	record: BOOLEAN
			-- Should user input be recorded?

	input_from_file: BOOLEAN
			-- Is the input to be read from a file?

	output_file: PLAIN_TEXT_FILE
			-- The output file for recording

	input_file: PLAIN_TEXT_FILE
			-- The input file when `input_from_file'

feature -- Status report

	symbol_list_initialized: BOOLEAN
			-- Has `symbol_list' been initialized?

feature {NONE} -- Implementation

	Help_character: CHARACTER is 'H'

	set_host_name is
			-- Set `host_name' and remove its settings from `contents'.
		do
			if option_in_contents ('h') then
				if contents.item.count > 2 then
					create host_name.make (contents.item.count - 2)
					host_name.append (contents.item.substring (
						3, contents.item.count))
					contents.remove
				else
					contents.remove
					if not contents.exhausted then
						create host_name.make (contents.item.count)
						host_name.append (contents.item)
						contents.remove
					else
						error_occurred := True
						log_errors (<<Hostname_error>>)
					end
				end
			end
		end

	set_port_number is
			-- Set `port_number' and remove its settings from `contents'.
		do
			from
				contents.start
			until
				contents.exhausted
			loop
				if contents.item.is_integer then
					port_number := contents.item.to_integer
					contents.remove
				else
					contents.forth
				end
			end
		end

	set_record_settings is
			-- Set `record' and `output_file' and remove their settings
			-- from `contents'.
		local
			file_name: STRING
		do
			if output_file /= Void then
				log_errors (<<Too_many_output_files_error>>)
			elseif option_in_contents ('r') then
				if contents.item.count > 2 then
					record := True
					create file_name.make (contents.item.count - 2)
					file_name.append (contents.item.substring (
						3, contents.item.count))
					contents.remove
				else
					contents.remove
					if not contents.exhausted then
						record := True
						create file_name.make (contents.item.count)
						file_name.append (contents.item)
						contents.remove
					else
						check
							not_recording: not record
						end
						error_occurred := True
						log_errors (<<Output_file_error>>)
					end
				end
			end
			if output_file = Void and record then
				create output_file.make (file_name)
				if not output_file.exists or else output_file.is_writable then
					output_file.open_write
				else
					check
						file_exists_and_is_not_writable:
							output_file.exists and not output_file.is_writable
					end
					error_occurred := True
					record := False
					log_errors (<<"File ", output_file.name,
						" is not writable.">>)
				end
			end
		end

	set_input_from_file_settings is
			-- Set `input_from_file' and `input_file' and remove their
			-- settings from `contents'.
		local
			file_name: STRING
		do
			if input_file /= Void then
				log_errors (<<Too_many_input_files_error>>)
			elseif option_in_contents ('i') then
				if contents.item.count > 2 then
					input_from_file := True
					create file_name.make (contents.item.count - 2)
					file_name.append (contents.item.substring (
						3, contents.item.count))
					contents.remove
				else
					contents.remove
					if not contents.exhausted then
						input_from_file := True
						create file_name.make (contents.item.count)
						file_name.append (contents.item)
						contents.remove
					else
						check
							not_file_input: not input_from_file
						end
						error_occurred := True
						log_errors (<<Input_file_error>>)
					end
				end
			end
			if input_file = Void and input_from_file then
				create input_file.make (file_name)
				if input_file.exists and then input_file.is_readable then
					input_file.open_read
				else
					error_occurred := True
					input_from_file := False
					if not input_file.exists then
						log_errors (<<"File ", input_file.name,
							" does not exist.">>)
					else
						log_errors (<<"File ", input_file.name,
							" is not readable.">>)
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
			Result.extend (agent set_host_name)
			Result.extend (agent set_port_number)
			Result.extend (agent set_record_settings)
			Result.extend (agent set_input_from_file_settings)
		end

	initialization_complete: BOOLEAN

feature {NONE} -- Implementation - Constants

	Output_file_error: STRING is
		"Output file for -r option was not specified.%N"

	Input_file_error: STRING is "Input file for -i option was not specified.%N"

	Too_many_input_files_error: STRING is
		"Input file (-i option) was specified more than once.%N"

	Too_many_output_files_error: STRING is
		"Output file (-r option) was specified more than once.%N"

	Hostname_error: STRING is "Host name for -h option was not specified.%N"


feature {NONE} -- ERROR_SUBSCRIBER interface

	notify (s: STRING) is
		do
			error_occurred := True
			error_description := s
		end

invariant

	host_name_exists: not error_occurred implies host_name /= Void
	output_file_exists_if_recording: not error_occurred implies 
		(record implies output_file /= Void and output_file.is_open_write)
	input_file_exists_if_input_from_file: not error_occurred implies 
		(input_from_file implies input_file /= Void and
		input_file.is_open_read)

end
