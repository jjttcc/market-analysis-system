indexing
	description: "An iterable list of tradables"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class TRADABLE_LIST inherit

	BILINEAR [TRADABLE [BASIC_MARKET_TUPLE]]
		redefine
			compare_references, compare_objects,
			changeable_comparison_criterion			
		end

	OPERATING_ENVIRONMENT
		export {NONE}
			all
		end

	GENERAL_UTILITIES
		export {NONE}
			all
		end

creation

	make

feature -- Initialization

	make (s_list: LIST [STRING]; factory: TRADABLE_FACTORY) is
		require
			not_void: s_list /= Void and factory /= Void
		do
			setup_symbol_list (s_list)
			symbol_list.compare_objects
			tradable_factory := factory
			object_comparison := True
			symbol_list.start
			cache_size := initial_cache_size
			create cache.make (cache_size)
			create cache_index_queue.make (cache_size)
		ensure
			sym_set: symbols /= Void and symbols.count = s_list.count
			factory_set: tradable_factory = factory
			implementation_init: target_tradable = Void and old_index = 0
			cache_initialized: cache /= Void
			cache_on: caching_on
			-- All elements of `s_list' are in `symbols',
			-- with upper-case characters changed to lower case.
		end

feature -- Access

	index: INTEGER is
		do
			Result := symbol_list.index
		end

	count: INTEGER is
			-- Number of items in the list
		do
			Result := symbol_list.count
		end

print_cache is
local
	indexes: LIST [INTEGER]
do
	indexes := cache_index_queue.linear_representation
	from
		print ("Cached indexes: ")
		indexes.start
	until
		indexes.islast or indexes.exhausted
	loop
		print (indexes.item.out + ", ")
		indexes.forth
	end
	if not indexes.off then
		print (indexes.item.out + "%N")
	end
end

	item: TRADABLE [BASIC_MARKET_TUPLE] is
			-- Current tradable.  `fatal_error' will be True if an error
			-- occurs.
		do
print ("TL item called%N")
print_cache
			fatal_error := False
			if index = old_index then
print ("A%N")
				check
					target_tradable_exists: target_tradable /= Void
				end
				if target_tradable_out_of_date then
print ("B%N")
					append_new_data
				end
			else
print ("C%N")
				check
					cursor_location_changed: index /= old_index
				end
				target_tradable := cached_item (index)
				if target_tradable = Void then
print ("D%N")
					load_target_tradable
				else
print ("E%N")
					if target_tradable_out_of_date then
print ("F%N")
						append_new_data
					end
					--!!!Check if this call belongs here or somewhere else or
					--!!!if it is needed at all:
					target_tradable.flush_indicators
				end
				old_index := index
			end
			Result := target_tradable
			if Result = Void then
				fatal_error := True
			end
		ensure then
			good_if_no_error: not fatal_error = (Result /= Void)
			old_index_updated: index = old_index
		end

-- !!!!Remove:
	old_item_remove: TRADABLE [BASIC_MARKET_TUPLE] is
			-- Current tradable.  `fatal_error' will be True if an error
			-- occurs.
		do
			fatal_error := False
			-- Create a new tradable (or get it from the cache) if
			-- the cursor has moved since the last tradable creation.
			if
				index /= old_index
			then
				old_index := 0
				target_tradable := cached_item (index)
				update_and_load_data
				old_index := index
			end
			Result := target_tradable
			if Result = Void and not fatal_error then
				fatal_error := True
			end
		ensure then
			good_if_no_error: not fatal_error implies Result /= Void
		end

	symbols: LIST [STRING] is
			-- The symbol of each tradable
		do
			if symbol_list_clone = Void then
				symbol_list_clone := clone (symbol_list)
			end
			Result := symbol_list_clone
		end

	changeable_comparison_criterion: BOOLEAN is False

	cache_size: INTEGER

feature -- Status report

	before: BOOLEAN is
		do
			Result := symbol_list.before
		end

	after: BOOLEAN is
		do
			Result := symbol_list.after
		end

	is_empty: BOOLEAN is
		do
			Result := symbol_list.is_empty
		end

	fatal_error: BOOLEAN
			-- Did an unrecoverable error occur?

	caching_on: BOOLEAN is
			-- Is caching of tradable data turned on?
		do
			Result := cache_index_queue.capacity > 0
		end

	timing_on: BOOLEAN
			-- Is timing of operations turned on?

feature -- Status setting

	turn_caching_on is
			-- Turn caching on if cache_size > 0.
		do
			if not caching_on then
				cache_index_queue.make (cache_size)
			end
		ensure
			on: cache_size > 0 implies caching_on
		end

	turn_caching_off is
			-- Turn caching off.
		do
			if caching_on then
				cache.clear_all
				cache_index_queue.make (0)
			end
		ensure
			off: not caching_on
		end

	clear_error is
			-- Clear error state.
		do
			fatal_error := False
		ensure
			no_error: fatal_error = False
		end

	set_timing_on (arg: BOOLEAN) is
			-- Set `timing_on' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			timing_on := arg
		ensure
			timing_on_set: timing_on = arg and timing_on /= Void
		end

feature -- Cursor movement

	start is
		do
			symbol_list.start
		end

	finish is
		do
			symbol_list.finish
		end

	forth is
		do
			symbol_list.forth
		end

	back is
		do
			symbol_list.back
		end

feature -- Basic operations

	search_by_symbol (s: STRING) is
			-- Find the tradable whose associated symbol matches `s'.
			-- Note: If `s' contains any upper-case characters, no matching
			-- tradable will be found.
		do
			from
				start
			until
				after or else symbol_list.item.is_equal (s)
			loop
				forth
			end
		ensure
			after_if_not_found: not symbols.has (s) implies after
			current_symbol_equals_s: item /= Void and
				not after implies item.symbol.is_equal (s)
		end

	clear_cache is
			-- Empty the cache.
		do
			cache.clear_all
			if count > 0 then
				start; back
			end
		ensure
			before: count > 0 implies before and index = 0
		end

feature {FACTORY} -- Access

	tradable_factory: TRADABLE_FACTORY
			-- Manufacturers of tradables

feature {NONE} -- Implementation

-- !!!!!!! OBSOLETE - Remove:
	update_and_load_data is
			-- Make sure, if appropriate, that the data in the data
			-- source is up to date, and then load the data.
		do
			if target_tradable = Void then
				load_data
			else
				-- Ensure that old indicator data from the previous
				-- `target_tradable' is not re-used.
				target_tradable.flush_indicators
			end
		end

	load_target_tradable is
			-- Load the data for `current_symbol' and set `target_tradable'
			-- to the resulting TRADABLE.
		require
			current_cached_item_void: cached_item (index) = Void
		do
print ("Data for " + current_symbol + " not in cache - loading%N")
			pre_process_data_load
			load_data
			post_process_data_load
		ensure
			target_tradable_set: not fatal_error = (target_tradable /= Void)
		end

--@@ Possibility: Split load_data into parts, some of which might be useable
-- (with a possible template pattern) for appending data.
	load_data is
			-- Load the data for `current_symbol' and close the input medium.
			-- `setup_input_medium' must have been called to open the
			-- input medium before calling this procedure.
			-- Set `target_tradable' to the resulting TRADABLE.
		require
		do
print ("Starting 'load_data' for " + current_symbol + "%N")
			setup_input_medium
			if not fatal_error then
				tradable_factory.set_symbol (current_symbol)
				tradable_factory.execute
				target_tradable := tradable_factory.product
-- !!!!Move add_to_cache to the caller of 'load_data'?
				add_to_cache (target_tradable, index)
				if tradable_factory.error_occurred then
					report_errors (target_tradable.symbol,
						tradable_factory.error_list)
					if tradable_factory.last_error_fatal then
						fatal_error := True
					end
				end
				close_input_medium
			else
				-- A fatal error indicates that the current tradable
				-- is invalid, or not readable, or etc., so ensure
				-- that target_tradable is not set to this invalid
				-- object.
				target_tradable := Void
			end
		end

	report_errors (symbol: STRING; l: LIST [STRING]) is
		do
			log_error ("Errors occurred while processing ")
			log_error (symbol); log_error (":%N")
			from
				l.start
			until
				l.after
			loop
				log_error (l.item)
				log_error ("%N")
				l.forth
			end
		end

	add_to_cache (t: TRADABLE [BASIC_MARKET_TUPLE]; idx: INTEGER) is
			-- Add 't' with its 'idx' to the cache if caching_on.  If not
			-- caching_on do nothing.
		require
			t_not_void: t /= Void
			valid_index: idx > 0
			t_loaded: t.loaded
		do
			if caching_on then
				if cache_index_queue.full then
					-- Remove oldest item.
					cache.remove (cache_index_queue.item)
					cache_index_queue.remove
				end
				cache.force (t, idx)
				cache_index_queue.put (idx)
			end
		ensure
			t_added_if_caching_on: caching_on implies cache @ idx = t
		end

	cached_item (i: INTEGER): TRADABLE [BASIC_MARKET_TUPLE] is
			-- The cached item with index 'i' - Void if not in cache
		do
			Result := cache @ i
		ensure
			void_if_no_caching: not caching_on implies Result = Void
		end

	cache: HASH_TABLE [TRADABLE [BASIC_MARKET_TUPLE], INTEGER]
			-- Cache of tradable/index for efficiency

	cache_index_queue: BOUNDED_QUEUE [INTEGER]

	old_index: INTEGER

	target_tradable: TRADABLE [BASIC_MARKET_TUPLE]
			-- The current tradable - used to produce `item'

	setup_input_medium is
			-- Ensure that tradable_list has access to the current
			-- input medium, if it exists.  `fatal_error' will be True
			-- if an error occurs.
		require
			no_error: fatal_error = False
		do
		end

	close_input_medium is
			-- Perform any required cleanup of the input medium, if it exists.
		do
		end

	current_symbol: STRING is
		do
			Result := symbol_list.item
		end

	setup_symbol_list (s_list: LINEAR [STRING]) is
			-- Create `symbol_list' and copy elements of s_list into it,
			-- converting any upper-case characters to lower-case.
		local
			s: STRING
			list: LINKED_LIST [STRING]
		do
			create list.make
			from
				s_list.start
			until
				s_list.exhausted
			loop
				s := clone (s_list.item)
				s.to_lower
				list.extend (s)
				s_list.forth
			end
			symbol_list := list
		end

	remove_current_item is
			-- Remove the current item and leave symbol_list cursor at
			-- the item after the removed item, if there is one; otherwise
			-- ensure symbol_list.first if it's not empty.
		require
			not_off: not off
		local
			i: INTEGER
		do
			i := symbol_list.index
			symbol_list.prune (symbol_list.item)
			if symbol_list.valid_cursor_index (i) then
				symbol_list.go_i_th (i)
			else
				symbol_list.start
			end
			symbol_list_clone := Void
		end

	symbol_list: LIST [STRING]

	symbol_list_clone: LIST [STRING]

	initial_cache_size: INTEGER is 10
			-- The initial size of the tradable cache
			-- @@Note: This feature should be moved to a globally accessible
			-- class and the value should be configurable by the user.

feature {NONE} -- Hook routines

	pre_process_data_load is
			-- Do any needed processing before calling `load_data'.
		do
			-- Null procedure - redefine if needed.
		end

	post_process_data_load is
			-- Do any needed processing after calling `load_data'.
		do
			-- Null procedure - redefine if needed.
		end

	target_tradable_out_of_date: BOOLEAN is
			-- Have new data become available for `target_tradable' since
			-- `target_tradable' was last updated?
		require
			target_tradable_exists: target_tradable /= Void
			current_item_is_cached: cached_item (index) /= Void
		do
			-- Default: Data is never out of date - Redefine in descendant
			-- (along with `append_new_data') if update behavior is required.
			Result := False
--!!!! temporary - force append for testing.
Result := True
		end

	append_new_data is
			-- Append newly available data to `target_tradable'.  (Note
			-- the difference between this procedure and the `load_data'
			-- procedure, which replaces the existing data instead of
			-- appending to it.)
		require
			target_tradable_exists: target_tradable /= Void
			current_item_is_cached: cached_item (index) /= Void
			symbols_correspond: equal (target_tradable.symbol, current_symbol)
			out_of_date: target_tradable_out_of_date
		do
			-- Default: Null procedure - Redefine in descendant (along with
			-- `out_of_date') if update behavior is required.
		ensure
			old_data_unchanged: (not target_tradable.data.is_empty implies
				target_tradable.data.first = old target_tradable.data.first)
				and then (old target_tradable.data.count > 1 implies
				target_tradable.data @ (old target_tradable.data.count) =
				old target_tradable.data.last)
			same_size_or_larger:
				target_tradable.data.count >= old target_tradable.data.count
		end

feature {NONE} -- Inapplicable

	compare_references is
		do
		end

	compare_objects is
		do
		end

invariant

	factory_not_void: tradable_factory /= Void
	always_compare_objects: object_comparison = True
	object_comparison_for_symbol_list: symbol_list.object_comparison
	cache_exists: cache /= Void and cache_index_queue /= Void
	cache_not_too_large: cache.count <= cache_size
	symbols_not_void: symbols /= Void
	index_definition: index = symbol_list.index
	non_negative_count: count >= 0
	valid_cache_size: cache_size >= 0

end -- class TRADABLE_LIST
