indexing
	description: "User interface for event registration"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class EVENT_REGISTRATION inherit

	GLOBAL_APPLICATION
		export
			{NONE} all
		undefine
			print
		end

	EXECUTION_ENVIRONMENT
		export
			{NONE} all
		undefine
			print
		end

	APP_ENVIRONMENT
		export
			{NONE} all
		undefine
			print
		end

	COMMAND_LINE_UTILITIES [MARKET_EVENT_GENERATOR]
		rename
			print_message as show_message
		export
			{NONE} all
		end

	EDITING_INTERFACE
		undefine
			print
		end

creation

	make

feature -- Initialization

	make (disp: EVENT_DISPATCHER; in_dev, out_dev: IO_MEDIUM) is
		require
			not_void: disp /= Void and in_dev /= Void and out_dev /= Void
		do
			dispatcher := disp
			input_device := in_dev
			output_device := out_dev
			!!help.make
			-- !!!Satisfy invariant - editor is currently not used; it may
			-- be used later - if not, might want to change the invariant or?
			!!editor
		ensure
			set: dispatcher = disp
			iodev_set: input_device = in_dev and output_device = out_dev
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
				print_list (<<"Select registrant type:%N     ",
					"User (u) Log file (l) Previous (-) Help (h) ", eom>>)
				inspect
					character_selection (Void)
				when 'u', 'U' then
					new_registrant := new_user
				when 'l', 'L' then
					new_registrant := new_log_file
				when 'h', 'H' then
					print (help @ help.Add_registrants)
				when '!' then
					print ("Type exit to return to main program.%N")
					system ("")
				when '-' then
					finished := True
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
			s1, s2, hist_file_name: STRING
			constants: expanded APPLICATION_CONSTANTS
		do
			!!s1.make (0); !!s2.make (0)
			print_list (<<"Enter the user's full name: ", eom>>)
			s1.append (input_string)
			print_list (<<"Enter the user's email address: ", eom>>)
			s2.append (input_string)
			!!hist_file_name.make (s2.count + 8)
			hist_file_name.append (s2); hist_file_name.append (".history")
			-- Ensure that the event history file name is unique:
			hist_file_name.append (s1.hash_code.out)
			!!Result.make (hist_file_name,
				constants.event_history_field_separator,
				constants.event_history_record_separator)
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
			print_list (<<"User was created with the following properties:%N",
						"name: ", Result.name, ", email address: ",
						Result.primary_email_address, "%Nmailer: ",
						Result.mailer, ", email subject flag: ",
						Result.email_subject_flag, "%N">>)
		end

	new_log_file: EVENT_LOG_FILE is
			-- Create a log file, input its properties from the user,
			-- and add it to the global market_event_registrants.
		local
			file_name, s2, history_file_name: STRING
			constants: expanded APPLICATION_CONSTANTS
		do
			!!file_name.make (0); !!s2.make (0)
			print_list (<<"Enter the file name: ", eom>>)
			file_name.append (input_string)
			!!history_file_name.make (file_name.count + 8)
			history_file_name.append (file_name)
			history_file_name.append (".history")
			!!Result.make (file_name, history_file_name,
				constants.event_history_field_separator,
				constants.event_history_record_separator)
			print_list (<<"Log file was created with the following %
						%properties:%N", "name: ", Result.name, "%N">>)
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
					print_list (
							<<"Select an event type for which to register ",
							r.name, " (0 to end):%N">>)
				until
					i > types.count
				loop
					print_list (<<i, ") ", types.item (i).name, "%N">>)
					i := i + 1
				end
				from
					print (eom)
					read_integer
				until
					last_integer >= 0 and last_integer <= i - 1
				loop
					print_list (<<"Selection must be between 0 and ",
								i - 1, " - try again: %N">>)
					print (eom)
					read_integer
				end
				if last_integer = 0 then
					finished := True
				else
					current_type := types @ last_integer
					r.add_event_type (current_type)
					print_list (<<"Added type ", current_type.name, ".%N">>)
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
				print (eom)
				read_integer
			until
				last_integer > 0 and last_integer < i or abort
			loop
				print_list (<<"Selection must be between 1 and ",
							i - 1, " - Abort selection? (y/n) ", eom>>)
				c := character_selection (Void)
				if c = 'y' or c = 'Y' then
					abort := True
				else
					print (eom)
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
				print (eom)
				read_integer
			until
				last_integer > 0 and last_integer < i or abort
			loop
				print_list (<<"Selection must be between 1 and ",
							i - 1, " - Abort selection? (y/n) ", eom>>)
				c := character_selection (Void)
				if c = 'y' or c = 'Y' then
					abort := True
				else
					print (eom)
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
					%Previous (-) Help (h) ", eom>>)
				inspect
					character_selection (Void)
				when 'r', 'R' then
					t := event_type_selection (r)
					if t /= Void then
						r.event_types.prune_all (t)
						print_list (<<"Event type ", t.name, " removed.%N">>)
					end
				when 'a', 'A' then
					add_event_types (r)
				when 'h', 'H' then
					print (help @ help.Edit_registrant)
				when '!' then
					print ("Type exit to return to main program.%N")
					system ("")
				when '-' then
					finished := True
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

feature {NONE} -- Implementation

	help: HELP

end -- class EVENT_REGISTRATION
