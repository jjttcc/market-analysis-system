indexing
	description: "Root class for the extended version of the %
		%Market Analysis Server"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class EXTENDED_MA_SERVER inherit

	MA_SERVER
		rename
			make as mas_make
		redefine
			prepare_for_listening, exit
		end

	ERROR_SUBSCRIBER

creation

	make

feature {NONE} -- Initialization

	make is
		local
			platform: expanded PLATFORM_DEPENDENT_OBJECTS
			cl_dummy: MAS_COMMAND_LINE
		do
			-- Force the platform's command-line to be an "extended" one.
			cl_dummy := platform.command_line_cell (extended_command_line).item
			create errors.make (0)
			mas_make
		end

	compile_this is
		local
			-- "proprietary" components that are not currently used.
			composite_tradable: COMPOSITE_TRADABLE
			basic_composite_tradable: BASIC_COMPOSITE_TRADABLE
		do
		end

	report_back (errs: STRING) is
			-- If command_line_options.report_back, send a status
			-- report back to the startup process.
		local
			connection: SERVER_RESPONSE_CONNECTION
			cl: EXTENDED_MAS_COMMAND_LINE
		do
			cl := extended_command_line
			if cl.report_back then
				create connection.make (cl.host_name_for_startup_report,
					cl.port_for_startup_report)
				-- If `errs.is_empty', the startup process will assume
				-- that this process started succefully.
				connection.send_one_time_request (errs, False)
			end
		end

feature {NONE} -- Implementation - Hook routines

	prepare_for_listening is
		do
			Precursor
			report_back (errors)
		end

	notify (msg: STRING) is
		do
			errors.append (msg + "%N")
		end

	exit (status: INTEGER) is
		do
			if command_line_options.error_occurred then
				errors := errors + command_line_options.error_description
			end
			report_back (errors)
			Precursor (status)
		end

feature {NONE} -- Implementation - Attributes

	errors: STRING
			-- List of error messages to "report back" to the startup process

	extended_command_line: EXTENDED_MAS_COMMAND_LINE is
		local
			platform: expanded EXTENDED_PLATFORM_DEPENDENT_OBJECTS
		do
			Result := platform.command_line
		end

end
