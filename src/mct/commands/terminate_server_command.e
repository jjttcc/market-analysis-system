indexing
	description: "MCT_COMMAND to terminate the server process"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class TERMINATE_SERVER_COMMAND inherit

	SESSION_COMMAND
		rename
			make as sc_make_unused
		redefine
			execute
		end

	GLOBAL_APPLICATION_FACILITIES
		export
			{NONE} all
		end

create

	make

feature -- Initialization

	make (id: STRING) is
		require
			id_exists: id /= Void
			id_not_empty: not id.is_empty
		do
			identifier := id
		ensure
			items_set: identifier = id
		end

feature -- Basic operations

	execute (window: SESSION_WINDOW) is
		local
			connection: CONNECTION
			proc: EPX_EXEC_PROCESS
		do
			create connection.start_conversation (
				window.host_name, window.port_number.to_integer)
			if connection.last_communication_succeeded then
				if debugging_on then
					print ("Connected with server.%N")
				end
				connection.send_termination_request (False)
				if debugging_on then
					if connection.last_communication_succeeded then
						print ("Termination request succeeded.%N")
					else
						-- @@This error should probably be displayed in a
						-- window as part of the normal flow so that the
						-- user knows something went wrong.
						print ("Termination request failed.%N")
						print (connection.error_report)
					end
				end
			else
				if debugging_on then
					-- @@This error should probably be displayed in a
					-- window as part of the normal flow so that the
					-- user knows something went wrong.
					print ("Server connection failed.%N")
					print (connection.error_report)
				end
			end
			connection.close
			-- Obtain the associated process and make sure it's terminated
			-- and removed from the process list.
			proc := associated_process (window)
			check
				process_is_ready_for_termination:
					proc.is_pid_valid and not proc.is_terminated
			end
			proc.wait_for (True)
			remove_process (window.host_name, window.port_number)
		ensure
			process_removed:
				not has_process (window.host_name, window.port_number)
		end

feature {NONE} -- Implementation

	associated_process (window: SESSION_WINDOW): EPX_EXEC_PROCESS is
			-- The process associated with Current
		require
			window_exists: window /= Void
		do
			Result := process_at (window.host_name, window.port_number)
		ensure
			exists: Result /= Void
		end

end
