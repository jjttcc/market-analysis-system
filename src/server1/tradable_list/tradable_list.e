indexing
	description: "An iterable list of tradables"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
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
			object_comparison := true
			symbol_list.start
			create cache.make (Cache_size)
			caching_on := true
		ensure
			sym_set: symbols /= Void and symbols.count = s_list.count
			factory_set: tradable_factory = factory
			implementation_init: last_tradable = Void and old_index = 0
			cache_initialized: cache /= Void
			ache_on: caching_on
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

	item: TRADABLE [BASIC_MARKET_TUPLE] is
			-- Current tradable.  `fatal_error' will be true if an error
			-- occurs.
		do
			fatal_error := false
			-- Create a new tradable (or get it from the cache) only if the
			-- cursor has moved since the last tradable creation.
			if
				not caching_on or
				index /= old_index or Cache_size > 0 and cache.count = 0
			then
				old_index := 0
				last_tradable := cached_item (index)
				if last_tradable = Void then
					setup_input_medium
					if not fatal_error then
						tradable_factory.set_symbol (current_symbol)
						tradable_factory.execute
						last_tradable := tradable_factory.product
						add_to_cache (last_tradable, index)
						if tradable_factory.error_occurred then
							report_errors (last_tradable.symbol,
								tradable_factory.error_list)
							if tradable_factory.last_error_fatal then
								fatal_error := true
							end
						end
						close_input_medium
					else
						-- A fatal error indicates that the current tradable
						-- is invalid, or not readable, or etc., so ensure
						-- that last_tradable is not set to this invalid
						-- object.
						last_tradable := Void
					end
				else
					last_tradable.flush_indicators
				end
				old_index := index
			end
			Result := last_tradable
			if Result = Void and not fatal_error then
				fatal_error := true
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

	changeable_comparison_criterion: BOOLEAN is false

	Cache_size: INTEGER is 10

feature -- Status report

	before: BOOLEAN is
		do
			Result := symbol_list.before
		end

	after: BOOLEAN is
		do
			Result := symbol_list.after
		end

	empty: BOOLEAN is
		do
			Result := symbol_list.empty
		end

	fatal_error: BOOLEAN
			-- Did an unrecoverable error occur?

	caching_on: BOOLEAN
			-- Is caching of tradable data turned on?

feature -- Status setting

	turn_caching_on is
			-- Turn caching on.
		do
			if not caching_on then
				caching_on := true
			end
		ensure
			on: caching_on
		end

	turn_caching_off is
			-- Turn caching off.
		do
			if caching_on then
				caching_on := false
			end
		ensure
			off: not caching_on
		end

	clear_error is
			-- Clear error state.
		do
			fatal_error := false
		ensure
			no_error: fatal_error = false
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
		end

feature {FACTORY} -- Access

	tradable_factory: TRADABLE_FACTORY
			-- Manufacturers of tradables

feature {NONE} -- Implementation

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
			not_void: t /= Void
		do
			if caching_on then
				if cache.count = Cache_size then
					cache.clear_all
					check cache.count = 0 end
				end
				cache.put(t, idx)
			end
		end

	cached_item (i: INTEGER): TRADABLE [BASIC_MARKET_TUPLE] is
			-- The cached item with index 'i' - Void if not in cache
		do
			if caching_on then
				Result := cache @ i
			end
		ensure
			void_if_no_caching: not caching_on implies Result = Void
		end

	cache: HASH_TABLE [TRADABLE [BASIC_MARKET_TUPLE], INTEGER]
			-- Cache of tradable/index for efficiency

	old_index: INTEGER

	last_tradable: TRADABLE [BASIC_MARKET_TUPLE]

	setup_input_medium is
			-- Ensure that tradable_list has access to the current
			-- input medium, if it exists.  `fatal_error' will be true
			-- if an error occurs.
		require
			no_error: fatal_error = false
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
			s: STRING
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

feature {NONE} -- Inapplicable

	compare_references is
		do
		end

	compare_objects is
		do
		end

invariant

	factory_not_void: tradable_factory /= Void
	always_compare_objects: object_comparison = true
	object_comparison_for_symbol_list: symbol_list.object_comparison
	cache_exists: cache /= Void
	cache_not_too_large: cache.count <= Cache_size
	symbols_not_void: symbols /= Void
	index_definition: index = symbol_list.index
	non_negative_count: count >= 0

end -- class TRADABLE_LIST
