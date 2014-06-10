note
	description:
		"Root class for the Configuration Tool, a program that allows %
		%configuration actions to be carried out without the need of %
		%external tools, such as Perl, that may not be available %
		%during installation on a Windows platform"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2004: Jim Cochrane - %
		%License to be determined"

class CONFIGURATION_TOOL inherit

	EXCEPTION_SERVICES
		export
			{NONE} all
		redefine
			application_name
		end

	ERROR_SUBSCRIBER
		export
			{NONE} all
		end

create

    make

feature {NONE} -- Initialization

	make
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
			if options.command_file_path /= Void then
				process_commands
			end
        end

	options: CONFIG_TOOL_COMMAND_LINE
		once
			create Result.make
		end

feature {NONE} -- Implementation

	process_commands
		local
			file_changer: FILE_PROCESSOR
		do
			create file_changer.make
			file_changer.add_error_subscriber (Current)
			file_changer.execute (options)
		end

feature {NONE} -- Implementation - hook routine implementations

	application_name: STRING = "application"

	notify (s: STRING)
		do
			print (s)
		end

end
