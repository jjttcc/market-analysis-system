indexing
	description: "Facilities for exception handling and program termination -%
	% intended to be used via inheritance"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

deferred class MAS_EXCEPTION inherit

	EXCEPTIONS
		export
			{NONE} all
		end

	UNIX_SIGNALS
		rename
			meaning as signal_meaning, ignore as ignore_signal,
			catch as catch_signal
		export
			{NONE} all
		end

	GLOBAL_APPLICATION
		export
			{NONE} all
		end

	GENERAL_UTILITIES
		export
			{NONE} all
		end

feature -- Access

	Error_exit_status: INTEGER is -1
			-- Error status for exit

	no_cleanup: BOOLEAN
			-- Should `termination_cleanup' NOT be called by `exit'?

feature -- Basic operations

	handle_exception (routine_description: STRING) is
		local
			error_msg: STRING
			fatal: BOOLEAN
		do
			-- An exception may have caused a lock to have been left open -
			-- ensure that clean-up occurs to remove the lock:
			no_cleanup := false
			if exception /= Signal_exception then
				if is_developer_exception then
					error_msg := developer_exception_name
				else
					error_msg := meaning (exception)
					fatal := fatal_exception (exception)
				end
				log_errors (<<"%NError encountered in ", routine_description,
							": ", error_msg, "%N">>)
				if fatal then
					exit (Error_exit_status)
				end
			elseif signal = Sigterm or signal = Sigabrt then
				log_errors (<<"%NCaught kill signal in ", routine_description,
					":%N", signal_meaning (signal), " (", signal, ")",
					" - exiting ...%N">>)
				exit (Error_exit_status)
			else
				log_errors (<<"%NCaught signal in ", routine_description,
					": ", signal_meaning (signal), " (", signal, ")",
					" - continuing ...%N">>)
			end
		end

	exit (status: INTEGER) is
			-- Exit the server with the specified status.  If `no_cleanup'
			-- is false, call `termination_cleanup'.
		do
			if status /= 0 then
				io.print ("Aborting the server.%N")
			else
				io.print ("Terminating the server.%N")
			end
			if not no_cleanup then
				debug ("persist")
					io.print ("Cleaning up ...%N")
				end
				termination_cleanup
				debug ("persist")
					io.print ("Finished cleaning up.%N")
				end
			end
			die (status)
		rescue
			-- Make sure that program terminates when an exception occurs.
			die (status)
		end

	fatal_exception (e: INTEGER): BOOLEAN is
			-- Is `e' an exception that is considered fatal?
		do
			Result := true
			if
				e = external_exception or e = floating_point_exception or
				e = routine_failure
			then
				Result := false
			end
		end

end -- GLOBAL_SERVER
