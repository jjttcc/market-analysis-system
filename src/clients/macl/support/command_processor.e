indexing
	description: "Objects responsible for processing user-supplied commands"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%License to be determined"

class COMMAND_PROCESSOR inherit

	REGULAR_EXPRESSION_UTILITIES
		rename match as re_match end

create

	make

feature -- Initialization

	make (rec: BOOLEAN) is
		do
			record := rec
			input_record := ""
			fatal_error := False
			error := False
			select_patterns := <<"Select[^?]*function",
				"Select[^?]*opera[nt][do]",
				"Select *an *indicator *for.*'s",
				"Select *indicator *to *view",
				"Select *an *object *for.*'s",
				"Select *the *[a-z]* *technical indicator",
				"Select *an *indicator *to *edit:",
				"^Added type.*\.$",
				"^User was created with the following properties:",
				"has.*leaf.*function.*-.*",
				"^Examining.*leaf.*function.*",
				"Select *the.*trading *period *type.*:",
				"Select specification for crossover detection:",
				"Select *a *market *analyzer",
				"Indicator *%".*%" *children:",
				-- Built to match "1) word\n.*" but not match
				-- "1) word   2) word.*":
				"^1\) [^)]*$">>
			create objects.make (0)
			create shared_objects.make (0)
			objects.compare_objects
			shared_objects.compare_objects
		end

feature -- Access

	product: STRING
			-- The processed user request to be sent to the server

	input_record: STRING
			-- Recorded input

feature -- Status report

	record: BOOLEAN
			-- Is input and output to be recorded?

	fatal_error: BOOLEAN

	error: BOOLEAN

feature -- Basic operations

	process_server_msg (s: STRING) is
			-- Process the message `s' from the server - if it includes
			-- an object selection list, save the list for processing.
		require
			s_exists: s /= Void
		do
			fatal_error := False
			error := False
			server_response_is_selection_list := False
			if invalid_pattern_match (s) then
				-- Server responded with "invalid input" message.
				error := True
			end
			if object_selection_match (s) then
				server_response_is_selection_list := True
				store_objects_from_selection_list (s)
			end
		end

	process_request (r: STRING) is
			-- Process the request, `r', to send to the server according to
			-- the stored object choice.  If there is no current choice,
			-- `product' will equal `r'; else `product' will be the
			-- specified choice, if there is a match.  If there is no
			-- match, fatal_error will be True.
		require
			r_exists: r /= Void
		local
			otable: HASH_TABLE [STRING, STRING]
			shared, key_matched: BOOLEAN
			work_string: STRING
		do
			otable := Void
			shared := False
			key_matched := False
			work_string := r
			if match (shared_pattern, r) then
				otable := shared_objects
				debug ("process")
					print ("Using shared list%N")
				end
				debug ("very verbose")
					print (otable.current_keys.out)
					print (otable.linear_representation.out)
				end
				work_string := sub (shared_pattern, "", r)
				debug ("process")
					print ("after sub - work_string: " + work_string + "%N")
				end
				shared := True
			else
				otable := objects
			end
			debug ("process")
				print ("Checking '" + work_string + "' with:%N")
			end
			debug ("very verbose")
				print (otable.current_keys.out)
				print (otable.linear_representation.out)
			end
			if
				server_response_is_selection_list and otable.has (work_string)
			then
				product := otable @ work_string
				debug ("process")
					print ("Matched: " + product)
				end
				key_matched := True
			else
				product := work_string
				debug ("process")
					print ("No match: " + product)
				end
			end
			if record then
				record_input (product, shared, key_matched)
			end
			product := product + "%N"
		ensure
			product_exists: product /= Void
		end

feature {NONE} -- Implementation

	object_selection_match (s: STRING): BOOLEAN is
			-- Does `s' match one of `select_patterns'?
		local
			patterns: LINEAR [STRING]
		do
			Result := False
			debug ("osm")
				print ("%NChecking for match of '" + s + "'%N")
			end
			from
				patterns := select_patterns.linear_representation
				patterns.start
			until
				Result or patterns.exhausted
			loop
				debug ("osm")
					print ("with '" + patterns.item + "'%N")
				end
				if match (patterns.item, s) then
					Result := True
				else
					patterns.forth
				end
			end
			debug ("osm")
				print ("%Nreturning Result of " + Result.out)
				if Result then
					print (" (with '" + patterns.item + "')%N")
				else
					print ("%N")
				end
			end
		end

	store_objects_from_selection_list (s: STRING) is
			-- Extract each "object" name and associated selection number
			-- from `s' and store this pair as key (number) and value
			-- (name) in either `objects' or `shared_objects' according
			-- to whether or not the "object" is shared.
		local
			lines: LIST [STRING]
		do
			objects.clear_all; shared_objects.clear_all
			-- Ensure that DOS-based text can be properly split on
			-- a newline by removing the carriage return:
			s.prune_all ('%R')
			lines := s.split ('%N')
			from
				lines.start
			until
				lines.exhausted
			loop
				debug ("sc")
					print ("lines.item: '" + lines.item + "'%N")
				end
				if
					match (selection_list_pattern, lines.item)
				then
					if
						match (two_column_selection_list_pattern, lines.item)
					then
						process_2_column_selection_line (objects, lines.item)
					else
						-- It's just a one-column selection list.
						process_selection_line (objects, lines.item)
					end
				elseif
					match (non_shared_pattern, lines.item) and
					objects.count > 0
				then
					-- `lines.item' indicates that the remaining items
					-- (lines) constitute the list of "non-shared objects".
					-- This means that `objects', which contains the
					-- already processed `lines', holds the list of
					-- "shared objects", so adjust the contents of
					-- shared_objects and objects accordingly.
					shared_objects := clone (objects)
					objects.clear_all
				end
				lines.forth
			end
		end

	record_input (s: STRING; shared, key_match: BOOLEAN) is
			-- Process `s', according to `shared' (`s' matched
			-- `shared_pattern') and `key_match' (a key associated with
			-- `s' was contained in an object table) and append the
			-- result to `input_record'.
		do
			debug ("ri")
				print ("ri - s, shared, key_match: '" + s + "', " +
					shared.out + ", " + key_match.out)
			end
			if server_response_is_selection_list then
				if key_match then
					if shared then
						input_record := input_record +
							shared_string + s + "%N"
					else
						input_record := input_record + s + "%N"
					end
				elseif objects.has_item (s) then
					debug ("ri")
						print (s + " in objects%N")
					end
					input_record := input_record + key_for (s, objects) + "%N"
				elseif shared_objects.has_item (s) then
					debug ("ri")
						print (s + " in shared objects%N")
					end
					input_record := input_record + shared_string +
						key_for (s, shared_objects) + "%N"
				else
					debug ("ri")
						print ("adding " + s + " to input record%N")
					end
					input_record := input_record + s + "%N"
				end
			else
				debug ("ri")
					print ("adding " +  s + " to input record%N")
				end
				input_record := input_record + s + "%N"
			end
		end

	key_for (s: STRING; objs: HASH_TABLE [STRING, STRING]): STRING is
			-- The key in `objs' for item `s'
		local
			l: LINEAR [STRING]
		do
			Result := ""
			l := objs.current_keys.linear_representation
			from
				l.start
			until
				l.exhausted
			loop
				if (objs @ l.item).is_equal (s) then
					Result := l.item
				end
				l.forth
			end
			debug ("kf")
				print ("key_for returning " + Result + "%N")
			end
		end

feature {NONE} -- Implementation - Regular expressions

	match (pattern, s: STRING): BOOLEAN is
			-- Does `s' match the regular expression `pattern'?
		do
			Result := re_match (pattern, s)
			if last_compile_failed then
				io.error.print (
					"Defect: regular expression compilation failed.%N")
				io.error.print (last_regular_expression.error_message +
					"%N(position: " +
					last_regular_expression.error_position.out +
					"%NPlease report this bug bug to the MAS developers.%N")
				fatal_error := True
				error := True
			end
		ensure
			last_regular_expression_exists: last_regular_expression /= Void
		end

	invalid_pattern_match (target: STRING): BOOLEAN is
			-- Does `target' match an "invalid" pattern?
		do
			Result := one_pattern_matches (
				invalid_patterns.linear_representation, target)
		end

feature {NONE} -- Implementation - Utilities

	process_selection_line (obj_table: HASH_TABLE [STRING, STRING];
		line: STRING) is
			-- Process the current `line' (from a selection list received
			-- from the server): Extract the "object number" and "object
			-- name" and insert this pair into `obj_table', where "object
			-- number" is the key and "object name" is the data item.
		local
			objname, objnumber: STRING
			work_string: STRING
		do
			work_string := sub ("\)", "", line)
			objnumber := sub (" .*", "", work_string)
			objname := sub ("^[^ ]*  *", "", work_string)
			-- Strip off trailing spaces:
			objname := sub ("[ %T]*$", "", objname)
			obj_table.force (objnumber, objname)
			debug ("sc")
				print ("Stored: " + obj_table @ objname + " (" +
					objname + ")%N")
			end
		end

	process_2_column_selection_line (obj_table: HASH_TABLE [STRING, STRING];
		line: STRING) is
			-- Process the current `line' (from a selection list received
			-- from the server) as a line from a two-column selection list:
			-- For each column: extract the "object number" and "object
			-- name" and insert this pair into `obj_table', where "object
			-- number" is the key and "object name" is the data item.
		local
			item1, item2: STRING
		do
			if
				match ("^([0-9]+\).*)[ %T]+([0-9]+\).*)[ %T]*", line)
			then
				item1 := last_regular_expression.captured_substring (1)
				item2 := last_regular_expression.captured_substring (2)
				process_selection_line (obj_table, item1)
				process_selection_line (obj_table, item2)
			else
				io.error.print ("Defect: object selection match failed to " +
					"match line:%N" + line +
					"%NPlease report this bug bug to the MAS developers.%N")
				fatal_error := True
				error := True
			end
		end

feature {NONE} -- Implementation - Attributes

	server_response_is_selection_list: BOOLEAN
			-- Is the last processed server response an
			-- "object-selection-list"?

	invalid_patterns: ARRAY [STRING] is
			-- Patterns for invalid or incorrect input
		once
			Result := <<"Invalid selection", "Selection must be between">>
		end

	non_shared_pattern: STRING is ".*List of valid non.shared objects:.*"

	shared_pattern: STRING is "shared *"
			-- Pattern indicating that the user response indicates a
			-- "shared" object

	shared_string: STRING is "shared "
			-- String used to label a user response as specifying a
			-- "shared" object

	select_patterns: ARRAY [STRING]
			-- Regular-expression patterns used to determine if
			-- an "object-selection-list" is being presented to the user

	objects: HASH_TABLE [STRING, STRING]
			-- Unshared objects listed in the last "object-selection-list"

	shared_objects: HASH_TABLE [STRING, STRING]
			-- Shared objects listed in the last "object-selection-list"

	selection_list_pattern: STRING is "^[1-9][0-9]*\)"
			-- Pattern indicating that the server has sent a "selection list"

	two_column_selection_list_pattern: STRING is
		"^[1-9][0-9]*\).*[ %T][1-9][0-9]*\)"
			-- Pattern indicating that the server has sent a 2-column
			-- "selection list"

invariant

	object_comparison: objects.object_comparison and
		shared_objects.object_comparison
	regular_expression_not_anchored: last_regular_expression /= Void implies
		not last_regular_expression.is_anchored

end
