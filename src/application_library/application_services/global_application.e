indexing
	description: "Global features needed by the application"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class

	GLOBAL_APPLICATION

feature {NONE} -- Utility

	current_date: DATE is
		do
			!!Result.make_now
		end

	current_time: TIME is
		do
			!!Result.make_now
		end

	register_for_termination (v: TERMINABLE) is
			-- Add `v' to termination_registrants.
		require
			not_registered: not termination_registrants.has (v)
		do
			termination_registrants.extend (v)
		end

	termination_cleanup is
			-- Send cleanup notification to all members of
			-- `termination_registrants'.  Since `termination_registrants'
			-- is a stack, they will be cleaned up in reverser of the order
			-- in which they were added (with `register_for_termination').
		do
			from
			until
				termination_registrants.empty
			loop
				termination_registrants.item.cleanup
				termination_registrants.remove
			end
		end

feature {NONE} -- Access

	termination_registrants: STACK [TERMINABLE] is
			-- Registrants for termination cleanup notification
		once
			!LINKED_STACK [TERMINABLE]!result.make
		end

	event_types: ARRAY [EVENT_TYPE] is
			-- All event types known to the system
		local
			i: INTEGER
		do
			!ARRAY [EVENT_TYPE]!Result.make (1,
				market_event_generation_library.count)
			from
				i := 1
				market_event_generation_library.start
			until
				market_event_generation_library.exhausted
			loop
				Result.put (market_event_generation_library.item.event_type, i)
				market_event_generation_library.forth
				i := i + 1
			end
		end

	new_event_type (name: STRING): EVENT_TYPE is
			-- Create a new EVENT_TYPE with name `name'.
			-- Note: A new MARKET_EVENT_GENERATOR should be created with
			-- this new event type and added to market_event_generation_library
			-- before the next event type is created.
		do
			!!Result.make (name, market_event_generation_library.count + 1)
		ensure
			not event_types.has (Result)
		end

	function_library: LIST [MARKET_FUNCTION] is
			-- All defined market functions
		local
			x: ANY
			mflist: TERMINABLE_MARKET_FUNCTION_LIST
		once
			print ("function_library called%N")
			x := storable_array @ Function_index
			if x = Void then
				-- The list has not been created and saved to persistent
				-- store yet, so it's time to create it and add it to
				-- storable_list.
				!!mflist.make
				storable_array.force (mflist, Function_index)
			else
				mflist ?= x
			end
			check
				list_not_void: mflist /= Void
			end
			-- Ensure that the list will be 'cleaned up' when the process ends.
			register_for_termination (mflist)
			Result := mflist
			print ("function_library returning%N")
		end

	market_event_generation_library: LIST [MARKET_EVENT_GENERATOR] is
			-- All defined event generators
		local
			x: ANY
			meg_list: TERMINABLE_EVENT_GENERATOR_LIST
		once
			print ("market_event_generation_library called%N")
			x := storable_array @ Event_generation_index
			if x = Void then
				-- The list has not been created and saved to persistent
				-- store yet, so it's time to create it and add it to
				-- storable_list.
				!!meg_list.make
				storable_array.force (meg_list, Event_generation_index)
			else
				meg_list ?= x
			end
			check
				list_not_void: meg_list /= Void
			end
			-- Ensure that the list will be 'cleaned up' when the process ends.
			register_for_termination (meg_list)
			Result := meg_list
			print ("market_event_generation_library returning%N")
		end

	active_event_generators: LIST [MARKET_EVENT_GENERATOR] is
			-- Event generators in which at least one event registrant
			-- is interested in.
		local
			registrants: LIST [MARKET_EVENT_REGISTRANT]
			generators: LIST [MARKET_EVENT_GENERATOR]
		do
			!LINKED_LIST [MARKET_EVENT_GENERATOR]!Result.make
			registrants := market_event_registrants
			generators := market_event_generation_library
			from
				registrants.start
			until
				registrants.exhausted
			loop
				from
					generators.start
				until
					generators.exhausted
				loop
					if
						-- If the current generator has not already been
						-- added to Result and the current registrant is
						-- intersted in that generator's event type, add
						-- it to Result.
						not Result.has (generators.item) and
							registrants.item.event_types.has (
								generators.item.event_type)
					then
						Result.extend (generators.item)
					end
					generators.forth
				end
				registrants.forth
			end
		end

	market_event_registrants: LIST [MARKET_EVENT_REGISTRANT] is
			-- All defined event registrants
		local
			x: ANY
			reg_list: LINKED_LIST [MARKET_EVENT_REGISTRANT]
		once
			print ("market_event_registrants called%N")
			x := storable_array @ Event_registrants_index
			if x = Void then
				-- The list has not been created and saved to persistent
				-- store yet, so it's time to create it and add it to
				-- storable_list.
				!!reg_list.make
				storable_array.force (reg_list, Event_registrants_index)
			else
				reg_list ?= x
			end
			check
				list_not_void: reg_list /= Void
			end
			Result := reg_list
			-- The registrants need to be registered for
			-- termination/cleanup when the process ends; and they need
			-- to load their (event) histories, which are stored in
			-- a separate file.
			from
				Result.start
			until
				Result.exhausted
			loop
				Result.item.load_history
				register_for_termination (Result.item)
				Result.forth
			end
			print ("market_event_registrants returning%N")
		end

feature {NONE} -- Constants

	default_input_file_name: STRING is "/tmp/tatest"
			-- Name of default input file if none is specified by the user

	storable_file_name: STRING is
			-- Name of the file containing persistent data
		local
			ta_env: expanded TAL_APP_ENVIRONMENT
		once
			Result := ta_env.file_name_with_app_directory ("persistent")
		end

	Event_registrants_index, Event_generation_index, Function_index:
		INTEGER is unique
			-- Indexes for elements of storable_array
			-- Note: If new indexes are added, change the creation procedure
			-- of the STORABLE_ARRAY (in storable_array) correspondingly.

feature {NONE} -- Implementation

	storable_array: STORABLE_ARRAY [ANY] is
			-- List of all persistent objects.  Since the list will be
			-- registered for termination when it is created and since it
			-- should be the last thing 'cleaned up', it should be called
			-- before any other object is registered for termination.
			-- (Termination cleanup uses a stack, so the first item
			-- registered will be the last one cleaned up.)
		local
			storable: STORABLE
		once
			print ("storable_array called%N")
			!!storable
			Result ?= storable.retrieve_by_name (storable_file_name)
			if Result = Void then
				!!Result.make (storable_file_name, Event_registrants_index,
								Function_index)
			end
			-- Ensure that the list will be saved when the process ends.
			register_for_termination (Result)
			print ("storable_array returning%N")
		end

end -- GLOBAL_APPLICATION
