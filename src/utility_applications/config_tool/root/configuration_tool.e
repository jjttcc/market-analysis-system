indexing
	description:
		"Root class for the MAS Control Terminal, an application to control %
		%the MAS server, charting client, and other MAS components"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class CONFIGURATION_TOOL inherit

	EXCEPTION_SERVICES
		export
			{NONE} all
		redefine
			application_name
		end

create

    make

feature {NONE} -- Initialization

	make is
        do
			if options.error_occurred then
				print (options.error_description)
				print (options.usage)
				exit (1)
			end
			if options.help then
				print (options.usage)
				exit (0)
			end
			if options.command_file /= Void then
				process_commands
			end
        end

	options: CONFIG_TOOL_COMMAND_LINE is
		once
			create Result.make
		end

feature {NONE} -- Implementation

	process_commands is
		local
			configuration: CONFIGURATION
		do
--          Check that configuration.target_file exists.
			create configuration.make (options.command_file)
			print ("cmd file is: " + options.command_file + "%N")
--			for each specification s in
--			  configuration.replacement_specifications:
--			    perform the substitution specified by s on
--				  configuration.target_file (as a regular expression)
		end

feature {NONE} -- Implementation - hook routine implementations

	application_name: STRING is "application"

end
