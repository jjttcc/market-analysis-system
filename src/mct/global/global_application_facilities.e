indexing
	description: "Global facilities needed by the application"
	author: "Jim Cochrane"
	date: "$Date$"
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class

	GLOBAL_APPLICATION_FACILITIES

feature -- Access

	current_processes: HASH_TABLE [EPX_EXEC_PROCESS, STRING] is
			-- Currently running, controlled processes
		once
			create Result.make (20)
		end

	process_at (hostname: STRING; port_number: STRING): EPX_EXEC_PROCESS is
			-- The process from `current_processes' associated with 
			-- `hostname' and `port_number'
		do
			Result := current_processes @ (hostname + port_number)
		ensure
			definition: (current_processes.has (hostname + port_number)
				implies Result /= Void) and Result =
				current_processes @ (hostname + port_number)
		end

feature -- Status report

	has_process (hostname, port_number: STRING): BOOLEAN is
			--
		do
			Result := current_processes.has (hostname + port_number)
		end

feature -- Element change

	add_process (p: EPX_EXEC_PROCESS; hostname, port_number: STRING) is
			-- Add process `p', associated with `hostname' and `port_number'
			-- to `current_processes'.
		do
			current_processes.put (p, hostname + port_number)
		end

	remove_process (hostname, port_number: STRING) is
			-- Remove the process associated with `hostname' and `port_number'
			-- from `current_processes'.
		do
			current_processes.remove (hostname + port_number)
		end

end
