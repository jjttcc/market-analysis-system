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

feature -- Status report

	symbol_list_initialized: BOOLEAN
			-- Has `symbol_list' been initialized?

feature {NONE} -- Implementation

	Help_character: CHARACTER is 'H'

	set_host_name is
			-- Set `host_name' and remove its settings from `contents'.
			-- Void if no host_name is specified
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
					end
				end
			end
		end

	set_port_number is
			-- Set `port_number' and remove its settings from `contents'.
			-- Empty if no port number is specified
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

feature {NONE} -- Implementation queries

	main_setup_procedures: LINKED_LIST [PROCEDURE [ANY, TUPLE []]] is
			-- List of the set_... procedures that are called
			-- unconditionally - for convenience
		once
			create Result.make
			Result.extend (agent set_host_name)
			Result.extend (agent set_port_number)
		end

	initialization_complete: BOOLEAN

feature {NONE} -- ERROR_SUBSCRIBER interface

	notify (s: STRING) is
		do
			error_occurred := True
			error_description := s
		end

invariant

	host_name_exists: host_name /= Void

end
