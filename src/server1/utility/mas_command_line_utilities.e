indexing
	description: "MAS Command-line user interface functionality"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MAS_COMMAND_LINE_UTILITIES inherit

	COMMAND_LINE_UTILITIES
		export
			{NONE} all
		redefine
			eom
		end

	MA_COMMUNICATION_PROTOCOL
		rename
			eom as network_eom,
			message_field_separator as output_field_separator,
			message_record_separator as output_record_separator,
			message_date_field_separator as output_date_field_separator,
			message_time_field_separator as output_time_field_separator
		export
			{NONE} all
		undefine
			print
		end

	EXECUTION_ENVIRONMENT
		export {NONE}
			all
		undefine
			print
		end

feature -- Status report

	is_console: BOOLEAN
			-- Is the command-line being run directly from a console?

feature -- Status setting

	set_console is
			-- Set `is_console' to `True'.
		do
			is_console := True
		ensure
			is_console: is_console
		end

	set_no_console is
			-- Set `is_console' to `False'.
		do
			is_console := False
		ensure
			is_console: not is_console
		end

feature {NONE} -- Implementation - Access

	date_time_selection (msg: STRING): DATE_TIME is
			-- Obtain the date and time to begin market analysis from the
			-- user and pass it to the event generators.
		local
			date: DATE
			time: TIME
			finished: BOOLEAN
		do
			create date.make_now
			create time.make_now
			if msg /= Void and not msg.is_empty then
				print_list (<<msg, "%N">>)
			end
			from
			until
				finished
			loop
				print_list (<<"Currently selected date and time: ", date, ", ",
								time, "%N">>)
				print_list (<<"Select action:",
					"%N     Set date (d) Set time (t) %
					%Set date relative to current date (r)%N%
					%     Set market analysis date %
					%to currently selected date (s) ", eom>>)
				inspect
					character_selection (Void)
				when 'd', 'D' then
					date := date_choice
				when 't', 'T' then
					time := time_choice
				when 'r', 'R' then
					date := relative_date_choice
				when 's', 'S' then
					finished := True
				else
					print ("Invalid selection%N")
				end
				print ("%N%N")
			end
			create Result.make_by_date_time (date, time)
			print_list (<<"Setting date and time for processing to ",
							Result.out, "%N">>)
		end

	eom: STRING is
			-- End of message indicator - "<Ctl>G" for stream socket,
			-- "" (empty string) for files (including stdin) and other types
		local
			file: FILE
			stream_socket: STREAM_SOCKET
		do
			if eom_cache = Void then
				file ?= input_device
				stream_socket ?= input_device
				if file /= Void then
					eom_cache := ""
				elseif stream_socket /= Void then
					eom_cache := network_eom
				else
					eom_cache := ""
				end
			end
			Result := eom_cache
		end

	eom_cache: STRING

	output_date_field_separator: STRING is "/"

	output_time_field_separator: STRING is ":"

feature {NONE} -- Implementation - utility routines

	execute_shell_command is
			-- If NOT `is_console', print an error message.
			-- Otherwise: [Execute `last_string' after removing an
			-- initial '!' if there is one.  If last_string is empty
			-- or is "!", simply start the default shell.]
		local
			cmd: STRING
		do
			if is_console then
				if last_string = Void then
					cmd := ""
				elseif last_string.count > 0 and last_string @ 1 = '!' then
					cmd := last_string.substring (2, last_string.count)
				else
					cmd := clone (last_string)
				end
				check
					cmd_exists: cmd /= Void
				end
				if cmd.is_empty then
					print ("Type exit to return to main program.%N")
				end
				system (cmd)
			else
				print ("Invalid selection%N")
			end
		end

feature {NONE} -- Implementation - date-related routines

	date_choice: DATE is
			-- Date obtained from user.
		do
			print_list (<<"Enter the date to use for analysis or %
				%hit <Enter> to use the%Ncurrent date (mm/dd/yyyy): ", eom>>)
			create Result.make_now
			from
				read_line
			until
				last_string.is_empty or Result.date_valid (
					last_string, Result.date_default_format_string)
			loop
				print_list (<<"Date format invalid, try again: ", eom>>)
				read_line
			end
			if not last_string.is_empty then
				create Result.make_from_string_default (last_string)
			end
			print_list (<<"Using date of ", Result, ".%N">>)
		end

	relative_date_choice: DATE is
			-- Date obtained from user.
		local
			period: CHARACTER
			period_name: STRING
		do
			create Result.make_now
			from
			until
				period = 'd' or period = 'm' or period = 'y'
			loop
				print_list (<<"Select period length:%N%
					%     day (d) month (m) year (y) ", eom>>)
				inspect
					character_selection (Void)
				when 'd', 'D' then
					period := 'd'
					period_name := "day"
				when 'm', 'M' then
					period := 'm'
					period_name := "month"
				when 'y', 'Y' then
					period := 'y'
					period_name := "year"
				else
					print ("Invalid selection%N")
				end
			end
			print_list (<<"Enter the number of ", period_name,
						"s to set date back relative to today: ", eom>>)
			from
				read_integer
			until
				last_integer >= 0
			loop
				print_list (<<"Invalid number, try again: ", eom>>)
				read_integer
			end
			inspect
				period
			when 'd' then
				Result.day_add (-last_integer)
			when 'm' then
				Result.month_add (-last_integer)
			when 'y' then
				Result.year_add (-last_integer)
			end
			print_list (<<"Using date of ", Result, ".%N">>)
		end

	time_choice: TIME is
			-- Time obtained from user.
		do
			create Result.make (0, 0, 0)
			print_list (<<"Enter the hour to use for analysis: ", eom>>)
			from
				read_integer
			until
				last_integer >= 0 and last_integer < Result.Hours_in_day
			loop
				print_list (<<"Invalid hour, try again: ", eom>>)
				read_integer
			end
			Result.set_hour (last_integer)
			print_list (<<"Enter the minute to use for analysis: ", eom>>)
			from
				read_integer
			until
				last_integer >= 0 and last_integer < Result.Minutes_in_hour
			loop
				print_list (<<"Invalid minute, try again: ", eom>>)
				read_integer
			end
			Result.set_minute (last_integer)
			print_list (<<"Using time of ", Result, ".%N">>)
		end

end
