indexing
	description: "An iterable list of tradables"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - %
		%see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class TRADABLE_LIST inherit

	LINEAR [TRADABLE [BASIC_MARKET_TUPLE]]
		redefine
			compare_references, compare_objects,
			changeable_comparison_criterion			
		end

	OPERATING_ENVIRONMENT
		export
			{NONE} all
		end

creation

	make

feature -- Initialization

	make (s_list: LINEAR [STRING]; factories: LINEAR [TRADABLE_FACTORY]) is
		require
			not_void: s_list /= Void and factories /= Void
			-- counts_equal: s_list.count = factories.count
		do
			symbol_list := s_list
			tradable_factories := factories
			object_comparison := True
			symbol_list.start; tradable_factories.start
			!HASH_TABLE [TRADABLE [BASIC_MARKET_TUPLE], INTEGER]! cache.make (
				cache_size)
		ensure
			set: symbol_list = s_list and tradable_factories = factories
			implementation_init: last_tradable = Void and old_index = 0
			cache_initialized: cache /= Void
		end

feature -- Access

	index: INTEGER is
		do
			Result := symbol_list.index
		end

	item: TRADABLE [BASIC_MARKET_TUPLE] is
		do
			check
				indices_equal: index = tradable_factories.index
			end
			-- Create a new tradable (or get it from the cache) only if the
			-- cursor has moved since the last tradable creation.
			if index /= old_index then
				old_index := 0
				last_tradable := cached_item (index)
				if last_tradable = Void then
					setup_input_medium
					tradable_factories.item.set_symbol (current_symbol)
					tradable_factories.item.execute
					last_tradable := tradable_factories.item.product
					add_to_cache (last_tradable, index)
					if tradable_factories.item.error_occurred then
						print_errors (last_tradable,
										tradable_factories.item.error_list)
					end
				else
					last_tradable.flush_indicators
				end
				old_index := index
			end
			Result := last_tradable
		end

	symbols: LIST [STRING] is
			-- The symbol of each tradable
		local
			snames: LINEAR[STRING]
		do
			snames := symbol_list
			create {LINKED_LIST[STRING]} Result.make
			from snames.start until snames.exhausted loop
				Result.extend(snames.item)
				snames.forth
			end
			Result.compare_objects
		ensure then
			object_comparison: Result.object_comparison
			-- Result.count = symbol_list.count
			-- The contents of Result are in the same order as the
			-- corresponding contents of `symbol_list'.
		end

	changeable_comparison_criterion: BOOLEAN is False

	cache_size: INTEGER is 10

feature -- Status report

	after: BOOLEAN is
		do
			Result := symbol_list.after
		end

	empty: BOOLEAN is
		do
			Result := symbol_list.empty
		end

feature -- Cursor movement

	start is
		do
			symbol_list.start
			tradable_factories.start
		end

	finish is
		do
			symbol_list.finish
			tradable_factories.finish
		end

	forth is
		do
			symbol_list.forth
			tradable_factories.forth
		end

feature -- Basic operations

	search_by_symbol (s: STRING) is
			-- Find the tradable whose associated symbol matches `s'.
		require
			has_symbol: symbols.has (s)
		local
			slist: LIST [STRING]
		do
			from
				slist := symbols
				slist.start
				start
			until
				after or else slist.item.is_equal (s)
			loop
				slist.forth
				forth
			end
		ensure
			current_symbol_equals_s: item.symbol.is_equal (s)
		end

feature {FACTORY} -- Access

	tradable_factories: LINEAR [TRADABLE_FACTORY]
			-- Manufacturers of tradables

feature {NONE} -- Implementation

	symbol_list: LINEAR [STRING]

	print_errors (t: TRADABLE [BASIC_MARKET_TUPLE]; l: LIST [STRING]) is
		do
			if l.count > 1 then
				print ("Errors occurred while processing ")
			else
				print ("Error occurred while processing ")
			end
			print (t.symbol); print (":%N")
			from
				l.start
			until
				l.after
			loop
				print (l.item)
				print ("%N")
				l.forth
			end
		end

	add_to_cache (t: TRADABLE [BASIC_MARKET_TUPLE]; idx: INTEGER) is
			-- Add 't' with its 'idx' to the cache
		require
			not_void: t /= Void
		do
			if cache.count = cache_size then
				cache.clear_all
				check cache.count = 0 end
			end
			cache.put(t, idx)
		end

	cached_item (i: INTEGER): TRADABLE [BASIC_MARKET_TUPLE] is
			-- The cached item with index 'i' - Void if not in cache
		do
			Result := cache @ i
		end

	cache: HASH_TABLE [TRADABLE [BASIC_MARKET_TUPLE], INTEGER]
			-- Cache of tradable/index for efficiency

	old_index: INTEGER

	last_tradable: TRADABLE [BASIC_MARKET_TUPLE]

	setup_input_medium is
			-- Ensure that tradable_list has access to the current
			-- input medium, if it exists.
		require
			tf_index_current: index = tradable_factories.index
		do
		end

	current_symbol: STRING is
		do
			Result := symbol_list.item
		end

feature {NONE} -- Inapplicable

	compare_references is
		do
		end

	compare_objects is
		do
		end

invariant

	factories_not_void: tradable_factories /= Void
	always_compare_objects: object_comparison = True
	cache_not_too_large: cache.count <= cache_size
	symbol_list_not_void: symbol_list /= Void
	index_definition: index = symbol_list.index

end -- class TRADABLE_LIST
