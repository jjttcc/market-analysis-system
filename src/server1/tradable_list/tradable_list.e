indexing
	description: "An iterable list of tradables"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - %
		%see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class TRADABLE_LIST inherit

	LINEAR [TRADABLE [BASIC_MARKET_TUPLE]]
		redefine
			compare_references, compare_objects,
			changeable_comparison_criterion			
		end

	OPERATING_ENVIRONMENT
		export
			{NONE} all
		end

feature -- Access

	symbols: LIST [STRING] is
			-- The symbol of each tradable
		deferred
		ensure
			Result /= Void
		end

	changeable_comparison_criterion: BOOLEAN is False

	cache_size: INTEGER is 10

feature -- Basic operations

	search_by_symbol (s: STRING) is
			-- Find the tradable whose associated symbol matches `s'.
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
			item /= Void implies item.symbol.is_equal (s)
			-- not (s in symbols) implies item = Void
		end

feature {FACTORY} -- Access

	tradable_factories: LINEAR [TRADABLE_FACTORY]
			-- Manufacturers of tradables

feature {NONE} -- Implementation

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

end -- class TRADABLE_LIST
