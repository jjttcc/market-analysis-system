indexing
	description: "User interface for event registration"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

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

	TERMINABLE
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

	GLOBAL_SERVER
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
			{ANY} input_device, output_device
		end

	EDITING_INTERFACE
		export
			{NONE} all
		undefine
			print
		end

	STORABLE_SERVICES [MARKET_EVENT_REGISTRANT]
		rename
			real_list as market_event_registrants,
			working_list as working_event_registrants,
			retrieve_persistent_list as force_event_registrant_retrieval,
			prompt_for_char as character_choice,
			edit_list as registrant_menu
		export
			{NONE} all
			{ANY} registrant_menu
		undefine
			print
		end

creation

	make

feature -- Initialization

	make (in_dev, out_dev: IO_MEDIUM) is
		require
			not_void: in_dev /= Void and out_dev /= Void
		do
			input_device := in_dev
			output_device := out_dev
			create help.make
			-- Satisfy invariant (editor is currently not used.)
			create editor
			register_for_termination (Current)
		ensure
			iodev_set: input_device = in_dev and output_device = out_dev
		end

feature -- Status setting

	set_input_device (i: IO_MEDIUM) is
			-- Set `input_device' to `i'.
		do
			input_device := i
		ensure
			set: input_device = i
		end

	set_output_device (i: IO_MEDIUM) is
			-- Set `output_device' to `i'.
		do
			output_device := i
		ensure
			set: output_device = i
		end

feature {NONE} -- Implementation

	do_edit is
			-- Menu for adding, removing, editing, and viewing event
			-- registrants
		local
			finished: BOOLEAN
			msg: STRING
		do
			from
				msg := main_msg
			until
				finished
			loop
				print (msg)
				inspect
					character_selection (Void)
				when 'a', 'A' then
					add_registrants
				when 'r', 'R' then
					remove_registrants
				when 'v', 'V' then
					view_registrants
				when 'e', 'E' then
					edit_registrants
				when 's', 'S' then
					if not changed or not ok_to_save then
						print ("Invalid selection%N")
					else
						save
					end
				when 'h', 'H' then
					print (help @ help.Edit_event_registrants)
				when '!' then
					print ("Type exit to return to main program.%N")
					system ("")
				when '-' then
					finished := True
				else
					print ("Invalid selection%N")
				end
				print ("%N%N")
				report_errors
				if changed and ok_to_save then
					msg := main_changed_msg
				else
					msg := main_msg
				end
			end
		end

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
					working_event_registrants.extend (new_registrant)
					changed := true
					print_list (<<new_registrant.name,
						" added as a new event registrant.%N">>)
				end
			end
		end

	remove_registrants is
		local
			r: MARKET_EVENT_REGISTRANT
		do
			if not working_event_registrants.empty then
				print ("Select registrant to remove:%N")
				r := registrant_selection
				if r /= Void then
					working_event_registrants.prune_all (r)
					changed := true
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
			if not working_event_registrants.empty then
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
			if not working_event_registrants.empty then
				print ("Select registrant to edit:%N")
				r := registrant_selection
				if r /= Void then
					edit_registrant (r)
				end
			else
				print ("There currently are no registrants.%N")
			end
		end

	new_user: EVENT_USER is
			-- Create a user and input its properties from the real user.
		local
			s1, s2, hist_file_name: STRING
			constants: expanded APPLICATION_CONSTANTS
		do
			create s1.make (0); create s2.make (0)
			print_list (<<"Enter the user's full name: ", eom>>)
			s1.append (input_string)
			print_list (<<"Enter the user's email address: ", eom>>)
			s2.append (input_string)
			create hist_file_name.make (s2.count + 8)
			hist_file_name.append (s2); hist_file_name.append (".history")
			-- Ensure that the event history file name is unique:
			hist_file_name.append (s1.hash_code.out)
			create Result.make (hist_file_name,
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
			-- Create a log file and input its properties from the user.
		local
			file_name, s2, history_file_name: STRING
			constants: expanded APPLICATION_CONSTANTS
		do
			create file_name.make (0); create s2.make (0)
			print_list (<<"Enter the file name: ", eom>>)
			file_name.append (input_string)
			create history_file_name.make (file_name.count + 8)
			history_file_name.append (file_name)
			history_file_name.append (".history")
			create Result.make (file_name, history_file_name,
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
				if event_types.empty then
					finished := true
					print ("No event types available to add.%N")
				end
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
					changed := true
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
				regs := working_event_registrants
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
				if types.empty then
					abort := true
				else
					print (eom)
					read_integer
				end
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
						changed := true
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

	working_event_registrants: STORABLE_LIST [MARKET_EVENT_REGISTRANT]

	main_msg: STRING is
		once
			Result := concatenation (<<"Select action:",
				"%N     Add registrants (a) Remove registrants (r) %
				%View registrants (v) %
				%%N     Edit registrants (e) Exit (x) Previous (-) %
				%Help (h) ", eom>>)
		end

	main_changed_msg: STRING is
		once
			Result := concatenation (<<"Select action:",
				"%N     Add registrants (a) Remove registrants (r) %
				%View registrants (v) %
				%%N     Edit registrants (e) Save changes (s) %
				%Previous - abort changes (-) %N%
				%     Help (h) ", eom>>)
		end

	initialize_working_list is
		do
			working_event_registrants := deep_clone (market_event_registrants)
		end

	reset_error is
		do
			error_occurred := false
		end

feature {NONE} -- Implementation of hook routines

	do_initialize_lock is
		do
			lock := file_lock (file_name_with_app_directory (
				registrants_file_name))
		end

end -- class EVENT_REGISTRATION
