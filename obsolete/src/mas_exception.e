indexing
	description: "Facilities for excpetion handling"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

deferred class MAS_EXCEPTION inherit

	EXCEPTIONS
		export
			{NONE} all
		undefine
			print
		end

	UNIX_SIGNALS
		rename
			meaning as signal_meaning, ignore as ignore_signal,
			catch as catch_signal
		export
			{NONE} all
		undefine
			print
		end

	GENERAL_UTILITIES
		export
			{NONE} all
		undefine
			print
		end

feature -- Access

	Error_exit_status: INTEGER is -1
			-- Error status for exit

feature -- Basic operations

	handle_exception (routine_description: STRING) is
		local
			error_msg: STRING
		do
			if not is_signal then
				if is_developer_exception then
					error_msg := developer_exception_name
				else
					error_msg := meaning (exception)
				end
				log_errors (<<"Error encounted in ", routine_description,
							": ", error_msg, "%N">>)
			else
				log_errors (<<"%NCaught signal in ", routine_description,
					": ", signal, ", continuing ...%N">>)
			end
		end

	exit (status: INTEGER) is
			-- Exit the server with the specified status
		do
			if status /= 0 then
				io.print ("Aborting the server.%N")
			else
				io.print ("Terminating the server.%N")
			end
			die (status)
		end

end -- GLOBAL_SERVER
