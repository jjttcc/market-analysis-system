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
			if assertion_violation then
				handle_assertion_violation
			elseif exception /= Signal_exception then
				if is_developer_exception then
					error_msg := developer_exception_name
					fatal := last_exception_status.fatal
				else
					error_msg := meaning (exception)
					fatal := last_exception_status.fatal or
						fatal_exception (exception)
				end
				log_errors (<<"%NError encountered in ", routine_description,
							":%N", error_msg, "%N">>)
			elseif
				signal = Sigterm or signal = Sigabrt or signal = Sigquit
			then
				log_errors (<<"%NCaught kill signal in ", routine_description,
					":%N", signal_meaning (signal), " (", signal, ")",
					" - exiting ...%N">>)
				fatal := true
			else
				log_errors (<<"%NCaught signal in ", routine_description,
					":%N", signal_meaning (signal), " (", signal, ")">>)
				fatal := last_exception_status.fatal
				if fatal then
					log_error(" - exiting ...%N")
				else
					log_error(" - continuing ...%N")
				end
			end
			if fatal then
				exit (Error_exit_status)
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

feature {NONE} -- Implementation

	handle_assertion_violation is
		local
			msg: STRING
		do
			msg := concatenation (<<"Assertion violation occurred in ",
				"routine `", recipient_name, "' with tag%N%"", tag_name,
				"%" from class %"", class_name,
				"%".%NType of assertion violation: ",
				meaning (exception), "%N">>)
			if not recipient_name.is_equal(original_recipient_name) then
				msg := concatenation (<<msg,
				"(Original routine where the violation occurred: ",
				original_recipient_name, ".)%N">>)
			end
			if not tag_name.is_equal(original_tag_name) then
				msg := concatenation (<<msg,
				"(Original tag name: ",
				original_tag_name, ".)%N">>)
			end
			if not class_name.is_equal(original_class_name) then
				msg := concatenation (<<msg,
				"(Original class name: ",
				original_class_name, ".)%N">>)
			end
			msg := concatenation (<<msg, "%N[Exception trace:%N",
				exception_trace, "]%N">>)
			log_error (msg)
			exit (Error_exit_status)
		end

end -- GLOBAL_SERVER
