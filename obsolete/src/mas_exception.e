indexing
	description: "Facilities for exception handling and program termination -%
	% intended to be used via inheritance"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

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

	Error_exit_status: INTEGER is 1
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
					error_msg := concatenation (<<":%N",
						developer_exception_name, "%N">>)
					fatal := last_exception_status.fatal
				else
					error_msg := "%N"
					fatal := last_exception_status.fatal or
						fatal_exception (exception)
				end
				log_errors (<<"%NError encountered - ", routine_description,
					error_msg, error_information ("Exception", false)>>)
			elseif
				signal = Sigterm or signal = Sigabrt or signal = Sigquit
			then
				log_errors (<<"%NCaught kill signal in ", routine_description,
					":%N", signal_meaning (signal), " (", signal, ")",
					"%NDetails: ", error_information ("Exception ", true),
					"%Nexiting ...%N">>)
				fatal := true
			else
				log_errors (<<"%NCaught signal in ", routine_description,
					":%N", signal_meaning (signal), " (", signal, ")",
					"%NDetails: ", error_information ("Exception ", true)>>)
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
			-- Sometimes die does not work - ensure program termination:
			end_program (status)
		rescue
			-- Make sure that program terminates when an exception occurs.
			die (status)
			end_program (status)
		end

	end_program (i: INTEGER) is
			-- Replacement for `die', since it appears to sometimes fail to
			-- exit
		external
			"C"
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

	exception_routine_string: STRING is
		do
			Result := recipient_name
			if Result /= Void and not Result.is_empty then
				Result := concatenation (<<"in ", "routine `", Result, "' ">>)
			else
				Result := ""
			end
		end

	tag_string: STRING is
		do
			Result := tag_name
			if Result /= Void and not Result.is_empty then
				Result := concatenation (<<"with tag:%N%"", Result, "%"%N">>)
			else
				Result := ""
			end
		end

	class_name_string: STRING is
		do
			Result := class_name
			if Result /= Void and not Result.is_empty then
				Result := concatenation (<<"from class %"", Result, "%".%N">>)
			else
				Result := ""
			end
		end

	exception_meaning_string (errname: STRING): STRING is
		do
			Result := meaning (exception)
			if Result /= Void and not Result.is_empty then
				if errname /= Void and not errname.is_empty then
					Result := concatenation (<<"Type of ", errname, ": ",
						Result>>)
				else
					Result := concatenation (<<"(", Result, ")">>)
				end
			else
				Result := ""
			end
		end

	error_information (errname: STRING; stack_trace: BOOLEAN): STRING is
			-- Information about the current exception, with a stack
			-- trace if `stack_trace'
		do
			if exception = Void_call_target then
				-- Feature call on void target is a special case that can
				-- cause problems (specifically, OS signal when calling
				-- class_name) - so handle it separately.
				Result := concatenation (<<errname, " occurred: ",
					meaning (exception), "%N[Exception trace:%N",
					exception_trace, "]%N">>)
			else
				Result := concatenation (<<errname, " occurred ",
					exception_routine_string, tag_string, class_name_string,
					exception_meaning_string (errname), "%N">>)
				if
					recipient_name /= Void and original_recipient_name /= Void
					and not recipient_name.is_equal(original_recipient_name)
				then
					Result := concatenation (<<Result,
					"(Original routine where the violation occurred: ",
					original_recipient_name, ".)%N">>)
				end
				if
					tag_name /= Void and original_tag_name /= Void and
					not tag_name.is_equal(original_tag_name)
				then
					Result := concatenation (<<Result,
					"(Original tag name: ",
					original_tag_name, ".)%N">>)
				end
				if
					class_name /= Void and original_class_name /= Void and
					not class_name.is_equal(original_class_name)
				then
					Result := concatenation (<<Result,
					"(Original class name: ",
					original_class_name, ".)%N">>)
				end
				if stack_trace then
					Result := concatenation (<<Result, "%N[Exception trace:%N",
						exception_trace, "]%N">>)
				end
			end
		end

	handle_assertion_violation is
		local
			msg: STRING
		do
			log_error (error_information ("Assertion violation", true))
			exit (Error_exit_status)
		end

end
