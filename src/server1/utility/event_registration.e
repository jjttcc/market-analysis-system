indexing
	description: "User interface for event registration"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class EVENT_REGISTRATION inherit

	GLOBAL_APPLICATION
		export {NONE}
			all
		end

	PRINTING
		export {NONE}
			all
		end

	EXECUTION_ENVIRONMENT
		export {NONE}
			all
		end

	TAL_APP_ENVIRONMENT
		export {NONE}
			all
		end

	STD_FILES
		export {NONE}
			all
		end

creation

	make

feature -- Initialization

	make (disp: EVENT_DISPATCHER) is
		require
			not_void: disp /= Void
		do
			dispatcher := disp
		ensure
			dispatcher = disp
		end

feature -- Access

	dispatcher: EVENT_DISPATCHER

feature -- Basic operations

	add_registrants is
		local
			finished: BOOLEAN
			new_registrant: MARKET_EVENT_REGISTRANT
		do
			from
			until
				finished
			loop
				new_registrant := Void
				print_list (<<"Select registrant type: ",
					"%N     User (u) Log file (l) Previous (-) ">>)
				inspect
					selected_character
				when 'u', 'U' then
					new_registrant := new_user
				when 'l', 'L' then
					new_registrant := new_log_file
				when '!' then
					print ("Type exit to return to main program.%N")
					system ("")
				when '-' then
					finished := true
				else
					print ("Invalid selection%N")
				end
				print ("%N%N")
				if new_registrant /= Void then
					add_event_types (new_registrant)
					add_registrant (new_registrant)
					print_list (<<new_registrant.name,
									" added as a new event registrant.%N">>)
				end
			end
		end

	remove_registrants is
		local
			r: MARKET_EVENT_REGISTRANT
		do
			if not market_event_registrants.empty then
				print ("Select registrant to remove:%N")
				r := registrant_selection
				if r /= Void then
					market_event_registrants.prune_all (r)
					print_list (<<"Event registrant ", r.name, " removed.%N">>)
				end
			else
				print ("There currently are no registrants.%N")
			end
		end

	view_registrants is
		local
			r: MARKET_EVENT_REGISTRANT
		do
			if not market_event_registrants.empty then
				print ("Select registrant to view:%N")
				r := registrant_selection
				if r /= Void then
					display_registrant (r)
				end
			else
				print ("There currently are no registrants.%N")
			end
		end

	edit_registrants is
		local
			r: MARKET_EVENT_REGISTRANT
		do
			if not market_event_registrants.empty then
				print ("Select registrant to edit:%N")
				r := registrant_selection
				if r /= Void then
					edit_registrant (r)
				end
			else
				print ("There currently are no registrants.%N")
			end
		end

feature {NONE} -- Implementation

	new_user: EVENT_USER is
			-- Create a user, input its properties from the real user,
			-- and add it to the global market_event_registrants.
		local
			s1, s2, s3: STRING
		do
			!!s1.make (0); !!s2.make (0)
			print ("Enter the user's full name: ")
			s1.append (input_string)
			print ("Enter the user's email address: ")
			s2.append (input_string)
			!!s3.make (s2.count + 8)
			s3.append (s2); s3.append (".history")
			!!Result.make (file_name_with_app_directory (s3))
			Result.set_name (s1)
			Result.add_email_address (s2)
			s1 := mailer
			if s1 = Void then -- Set to default
				s1 := "elm"
			end
			Result.set_mailer (s1)
			s1 := mailer_subject_flag
			if s1 = Void then -- Set to default
				s1 := "-s"
			end
			Result.set_email_subject_flag (s1)
			print ("User was created with the following properties:%N")
			print ("name: "); print (Result.name)
			print (", email address: "); print (Result.primary_email_address)
			print ("%Nmailer: "); print (Result.mailer)
			print (", email subject flag: "); print (Result.email_subject_flag)
			print ("%N")
		end

	new_log_file: EVENT_LOG_FILE is
			-- Create a log file, input its properties from the user,
			-- and add it to the global market_event_registrants.
		local
			file_name, s2, history_file_name: STRING
		do
			!!file_name.make (0); !!s2.make (0)
			print ("Enter the file name: ")
			file_name.append (input_string)
			!!history_file_name.make (file_name.count + 8)
			history_file_name.append (file_name)
			history_file_name.append (".history")
			!!Result.make (file_name_with_app_directory (file_name),
						file_name_with_app_directory (history_file_name))
			print ("Log file was created with the following properties:%N")
			print ("name: "); print (Result.name); print ("%N")
		end

	add_event_types (r: EVENT_REGISTRANT_WITH_HISTORY) is
			-- Input event types and add them to `r'.
		local
			i: INTEGER
			types: ARRAY [EVENT_TYPE]
			finished: BOOLEAN
			current_type: EVENT_TYPE
			c: CHARACTER
		do
			from
			until
				finished
			loop
				from
					i := 1
					types := event_types
				until
					i > types.count
				loop
					print_list (<<i, ") ", types.item (i).name, "%N">>)
					i := i + 1
				end
				from
					read_integer
				until
					last_integer >= 0 and last_integer <= i - 1
				loop
					print_list (<<"Selection must be between 0 and ",
								i - 1, " - try again: %N">>)
					read_integer
				end
				if last_integer = 0 then
					finished := true
				else
					current_type := types @ last_integer
					r.add_event_type (current_type)
					print_list (<<"Added type ", current_type.name, "%N">>)
					print ("Add another event type? (y/n) ")
					c := selected_character
					if not (c = 'y' or c = 'Y') then
						finished := true
					end
				end
			end
		end

	registrant_selection: MARKET_EVENT_REGISTRANT is
		local
			i: INTEGER
			regs: LIST [MARKET_EVENT_REGISTRANT]
			c: CHARACTER
			abort: BOOLEAN
		do
			from
				i := 1
				regs := market_event_registrants
				regs.start
			until
				regs.exhausted
			loop
				print_list (<<i, ") ", regs.item.name, "%N">>)
				i := i + 1
				regs.forth
			end
			from
				read_integer
			until
				last_integer > 0 and last_integer < i or abort
			loop
				print_list (<<"Selection must be between 1 and ",
							i - 1, " - Abort selection? (y/n) ">>)
				c := selected_character
				if c = 'y' or c = 'Y' then
					abort := true
				else
					read_integer
				end
			end
			if not abort then
				Result := regs @ last_integer
				print_list (<<Result.name, " selected.%N">>)
			end
		end

	event_type_selection (r: MARKET_EVENT_REGISTRANT): EVENT_TYPE is
		local
			i: INTEGER
			types: CHAIN [EVENT_TYPE]
			c: CHARACTER
			abort: BOOLEAN
		do
			from
				i := 1
				types := r.event_types
				types.start
			until
				types.exhausted
			loop
				print_list (<<i, ") ", types.item.name, "%N">>)
				i := i + 1
				types.forth
			end
			from
				read_integer
			until
				last_integer > 0 and last_integer < i or abort
			loop
				print_list (<<"Selection must be between 1 and ",
							i - 1, " - Abort selection? (y/n) ">>)
				c := selected_character
				if c = 'y' or c = 'Y' then
					abort := true
				else
					read_integer
				end
			end
			if not abort then
				Result := types @ last_integer
				print_list (<<Result.name, " selected.%N">>)
			end
		end

	add_registrant (r: MARKET_EVENT_REGISTRANT) is
			-- Add `r' to `market_event_registrants', register it with
			-- the `dispatcher', and register it for termination cleanup.
		do
			market_event_registrants.extend (r)
			dispatcher.register (r)
			register_for_termination (r)
		end

	display_registrant (r: MARKET_EVENT_REGISTRANT) is
		local
			l: LINEAR [EVENT_TYPE]
		do
			print_list (<<"Registrant ", r.name, " is registered for the %
							%following event types:%N">>)
			from
				l := r.event_types.linear_representation
				l.start
			until
				l.exhausted
			loop
				print_list (<<"ID: ", l.item.ID, ", name: ",
							l.item.name, "%N">>)
				l.forth
			end
		end

	edit_registrant (r: MARKET_EVENT_REGISTRANT) is
		local
			finished: BOOLEAN
			t: EVENT_TYPE
		do
			from
			until
				finished
			loop
				print_list (<<"Select action for ", r.name, ": ",
					"%N     Remove event type (r) Add event types (a) %
					%Previous (-) ">>)
				inspect
					selected_character
				when 'r', 'R' then
					t := event_type_selection (r)
					if t /= Void then
						r.event_types.prune_all (t)
						print_list (<<"Event type ", t.name, " removed.%N">>)
					end
				when 'a', 'A' then
					add_event_types (r)
				when '!' then
					print ("Type exit to return to main program.%N")
					system ("")
				when '-' then
					finished := true
				else
					print ("Invalid selection%N")
				end
				print ("%N%N")
			end
		end

	input_string: STRING is
			-- A string input by the user
		do
			from
				read_line
			until
				last_string /= Void
			loop
				read_line
			end
			Result := last_string
		end

	selected_character: CHARACTER is
			-- Character selected by user
			-- (Duplicated from TEST_USER_INTERFACE; at some point, a new
			-- class should be created for utility functions like this one.)
		do
			from
				Result := '%U'
			until
				Result /= '%U'
			loop
				read_line
				if laststring.count > 0 then
					Result := laststring @ 1
				end
			end
		end

end -- class EVENT_REGISTRATION
