indexing
	description: "MAS_COMMAND_LINE with extensions"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class EXTENDED_MAS_COMMAND_LINE inherit

	MAS_COMMAND_LINE
		redefine
			usage, main_setup_procedures, log_errors
		end

	ERROR_PUBLISHER
		export
			{ERROR_SUBSCRIBER} all
		undefine
			log_errors
		end

	REPORT_BACK_PROTOCOL
		export
			{NONE} all
		end

creation

	make

feature -- Access

	usage: STRING is
			-- Message: how to invoke the program from the command-line
		do
			Result := Precursor +
				"  -report_back <hostname>^<number>%N%
				%                       Report back the %
				%startup-status at host <hostname>%N%
				%                         on port number <number>.%N"
		end

feature -- Access -- settings

	report_back: BOOLEAN is
			-- Has a report been requested by the process that started
			-- up this process on whether this process started successfully?
		do
			Result := port_for_startup_report > 0
		end

	host_name_for_startup_report: STRING
			-- Host name to use for sending a status report back to
			-- the process that started up this process

	port_for_startup_report: INTEGER
			-- Port number to use for sending a status report back to
			-- the process that started up this process

feature {NONE} -- Implementation

	set_report_back_settings is
			-- Set settings used for the "report-back" option.
		do
			from
				contents.start
			until
				contents.exhausted
			loop
				if
					current_contents_match (Report_back_flag)
				then
					contents.remove
					if not contents.exhausted then
						set_startup_settings
						contents.remove
					else
						log_error (Missing_port)
					end
				else
					contents.forth
				end
			end
		end

		set_startup_settings is
				-- Set `host_name_for_startup_report' and
				-- `port_for_startup_report' from `contents.item'.
			require
				item_exists: contents.item /= Void
			local
				l: LIST [STRING]
				port: STRING
			do
				l := contents.item.split (Host_port_separator)
				if l.count /= 2 then
					log_error (Invalid_format + ": " + contents.item)
				else
					host_name_for_startup_report := l @ 1
					port := l @ 2
					if port.is_integer then
						port_for_startup_report := port.to_integer
					else
						log_error (Invalid_port_number + ": " + port)
					end
				end
			end

feature {NONE} -- Implementation - Hook routines

	log_errors (list: ARRAY [ANY]) is
			-- Log `list' of error messages.  If any element of `list' is
			-- longer than `Maximum_message_length', only the first
			-- `Maximum_message_length' characters of that element will
			-- be logged.
		do
			Precursor (list)
			list.linear_representation.do_all (agent publish_error)
		end

feature {NONE} -- Implementation queries

	Missing_port: STRING is "Missing port number for report-back option"

	Invalid_format: STRING is "Invalid format for report-back option"

	Invalid_port_number: STRING is "Invalid port number for report-back option"

	main_setup_procedures: LINKED_LIST [PROCEDURE [ANY, TUPLE []]] is
		do
			Result := Precursor
			Result.extend (agent set_report_back_settings)
		end

invariant

end
