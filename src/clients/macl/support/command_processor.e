indexing
	description: "Objects responsible for processing user-supplied commands"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class COMMAND_PROCESSOR

create

	make

feature -- Initialization

	make (rec: BOOLEAN) is
		do
			record := rec
			input_record := ""
			fatal_error := false
			error := false
			select_patterns := <<"%N*Select[^?]*function",
				"%N*Select[^?]*opera[nt][do]",
				"%N*Select *an *indicator *for.*'s",
				"%N*Select *indicator *to *view",
				"%N*Select *an *object *for.*'s",
				"%N*Select *the *[a-z]* *technical indicator",
				"%N*Select *an *indicator *to *edit:",
				"Added type.*\.$",
				"User was created with the following properties:",
				".*has.*leaf.*function.*-.*",
				"Examining.*leaf.*function.*",
				"%N*Select *the.*trading *period *type.*:",
				".*%N*Select specification for crossover detection:",
				"%N* *Select *a *market *analyzer",
				" *Indicator *%".*%" *children:",
				"1) ">>
			create objects.make (0)
			create shared_objects.make (0)
		end

feature -- Access

	product: STRING

	input_record: STRING
			-- Recorded input (!!check)

feature -- Status report

	record: BOOLEAN
			-- Is input and output to be recorded? (!!check)

	fatal_error: BOOLEAN

	error: BOOLEAN

feature -- Basic operations

--!!!Remove last_msg if it's not used:
	last_msg: STRING

	set_server_msg (msg: STRING) is
			-- Set the current message from the server and, if includes
			-- an object selection, save the choices for processing.
		do
			fatal_error := false
			error := false
			selection := false
--!!!Remove last_msg if it's not used:
			last_msg := msg
			if
--!!!!Note: regular expression match test here:
--				match(invalid_pattern, msg) /= -1
False--!!!
			then
				error := true
			end
			if select_object_match(msg) then
				selection := true
				store_choices(msg)
			end
		end

	process (response: STRING) is
			-- Process the response to send to the server according to
			-- the stored object choice.  If there is not current choice,
			-- result will equal response; else result will be the
			-- specified choice, if there is a match.  If there is no
			-- match, fatal_error will be true.
		local
			otable: HASH_TABLE [STRING, STRING]
			shared, key_matched: BOOLEAN
		do
			otable := Void
			shared := false
			key_matched := false
			if
--!!!!Note: regular expression match test here:
--				match(shared_pattern, response) /= -1
True--!!!
			then
				otable := shared_objects
--				print "Using shared list"
--				print otable.items()
--!!!Fix:				response := sub(shared_pattern, "", response)
				shared := true
			else
				otable := objects
			end
--			print "Checking '" + response + "' with:%N"
--			print otable.items()
			if selection and otable.has (response) then
				product := otable @ response
--				print "Matched: " + product
				key_matched := true
			else
				product := response
--				print "No match: " + product
			end
			if record then
				record_input(product, shared, key_matched)
			end
			product := product + "%N"
		end

feature {NONE} -- Implementation

	select_object_match (s: STRING): BOOLEAN is
		local
			patterns: LINEAR [STRING]
		do
			Result := false
			debug
				print ("Checking for match of '" + s + "'%N")
			end
			from
				patterns := select_patterns.linear_representation
				patterns.start
			until
				Result or patterns.exhausted
			loop
--				print "with " + pattern
				if
--!!!!Note: regular expression match test here:
--					match(patterns.item, s) /= -1
True --!!!
				then
					Result := true
				end
				patterns.forth
			end
			debug
				print ("returning Result of " + Result.out + "%N")
			end
		end

	store_choices (s: STRING) is
		local
			lines: LIST [STRING]
			objname, objnumber: STRING
		do
			objects.clear_all; shared_objects.clear_all
			--@@Will this work on Windows?:
			lines := s.split('%N')
			from
--!!!for l in lines:
				lines.start
			until
				lines.exhausted
			loop
				debug
					print ("lines.item: " + lines.item + "%N")
				end
				if
--!!!!Note: regular expression match test here:
--					match("^[1-9][0-9]*)", lines.item) /= -1
True--!!!
				then
objname := "tmp_dummy_name"
objnumber := "123"
--!!Fix:					lines.item := sub(")", "", lines.item)
--!!Fix:					objnumber := sub(" .*", "", lines.item)
--!!Fix:					objname := sub("^[^ ]*  *", "", lines.item)
					--!!!put or force?:
					objects.put (objnumber, objname)
					debug
						print ("Stored: " + objects @ objname + " (" +
							objname + ")%N")
					end
				elseif
--!!!!Note: regular expression match test here:
--					match(non_shared_pattern, lines.item) /= -1 and
--					len(objects) > 0
True--!!!
				then
					shared_objects := clone (objects)
					objects.clear_all
				end
				lines.forth
			end
		end

	record_input (s: STRING; shared, key_match: BOOLEAN) is
		do
--			print "ri - s, shared, key_match: '" + s + "', " + `shared` +
--				", " + `key_match`
			if selection then
				if key_match then
					if shared then
						-- !!Check use of s here:
						input_record := input_record +
							shared_string + s + "%N"
					else
						-- !!Check use of s here:
						input_record := input_record + s + "%N"
					end
				elseif objects.has_item (s) then
					-- ^^^^^^^^^^^^^^^^ !!check re. object_comparison.
--					print s + " in objects"
					input_record := input_record +
						key_for(s, objects) + "%N"
				elseif shared_objects.has_item (s) then
					--         ^^^^^^^^^^^^^^^^ !!check re. object_comparison.
--					print s + " in shared objects"
					input_record := input_record + shared_string +
						key_for(s, shared_objects) + "%N"
				else
--					print "adding " + s + " to input record"
					input_record := input_record + s + "%N"
				end
			else
--				print "adding " +  Result + " to input record"
				input_record := input_record + product + "%N"
			end
		end

	key_for (s: STRING; objs: HASH_TABLE [STRING, STRING]): STRING is
--!!!Not sure of generic arg types in HASH_TABLE.
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
			debug
				print ("key_for returning " + Result + "%N")
			end
		end

	selection: BOOLEAN

	invalid_pattern: STRING is "Invalid selection"

	non_shared_pattern: STRING is ".*List of all valid objects:.*"

	shared_pattern: STRING is "shared *"

	shared_string: STRING is "shared "

	select_patterns: ARRAY [STRING] -- Type?!!

	objects: HASH_TABLE [STRING, STRING]

	shared_objects: HASH_TABLE [STRING, STRING]

end
