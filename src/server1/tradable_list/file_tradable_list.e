indexing
	description:
		"An abstraction that provides a virtual list of tradables by %
		%holding a list that contains the input data file name of each %
		%tradable and loading the current tradable from its input file, %
		%giving the illusion that it is iterating over a list of tradables %
		%in memory.  The purpose of this scheme is to avoid using the %
		%large amount of memory that would be required to hold a large %
		%list of tradables in memory at once."
	NOTE: "!!!A useful extension would be to allow setting of a default %
		%factory:  If the current item in tradable_factories is Void, %
		%the default will be used.  This way, the client will not need %
		%to add a factory reference to tradable_factories for each element %
		%of file_names (although they will still need to add the Void %
		%elements)."
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class VIRTUAL_TRADABLE_LIST inherit

	TRADABLE_LIST
		redefine
			compare_references, compare_objects,
			changeable_comparison_criterion
		end

creation

	make

feature -- Initialization

	make (filenames: LINEAR [STRING]; factories: LINEAR [TRADABLE_FACTORY]) is
		require
			not_void: filenames /= Void and factories /= Void
			-- counts_equal: filenames.count = factories.count
		do
			file_names := filenames
			tradable_factories := factories
			object_comparison := true
			file_names.start; tradable_factories.start
			!LINKED_LIST[PAIR [TRADABLE [BASIC_MARKET_TUPLE], INTEGER]]!
				cache.make
			cache_size := 5
		ensure
			set: file_names = filenames and tradable_factories = factories
			implementation_init: last_tradable = Void and old_index = 0
			cache_initialized: cache /= Void and cache_size = 5
		end

feature -- Access

	index: INTEGER is
		do
			Result := file_names.index
		end

	item: TRADABLE [BASIC_MARKET_TUPLE] is
		local
			input_file: PLAIN_TEXT_FILE
		do
			check
				indexes_equal: file_names.index = tradable_factories.index
			end
			-- Create a new tradable (or get it from the cache) only if the
			-- cursor has moved since the last tradable creation.
			if file_names.index /= old_index then
				last_tradable := cached_item (file_names.index)
				if last_tradable = Void then -- If it wasn't in the cache
					input_file := open_current_file
					if input_file /= Void then
						tradable_factories.item.set_input_file (input_file)
						tradable_factories.item.set_symbol (
							symbol_from_file_name (file_names.item))
						tradable_factories.item.execute
						last_tradable := tradable_factories.item.product
						add_to_cache (last_tradable, file_names.index)
						if tradable_factories.item.error_occurred then
							print_errors (last_tradable,
											tradable_factories.item.error_list)
						end
					end
				end
				old_index := file_names.index
			end
			Result := last_tradable
		end

	search_by_file_name (name: STRING) is
		do
			from
				start
			until
				file_names.item.is_equal (name) or after
			loop
				forth
			end
		ensure then
			-- `file_names' contains `name' implies
			--	file_names.item.is_equal (name)
		end

	search_by_symbol (s: STRING) is
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
		ensure then
			-- `symbols' contains `s' implies
			--	file_names.item corresponds to `s'
		end

	file_names: LINEAR [STRING]

feature -- Status report

	after: BOOLEAN is
		do
			Result := file_names.after
		end

	empty: BOOLEAN is
		do
			Result := file_names.empty
		end

	changeable_comparison_criterion: BOOLEAN is false

feature -- Cursor movement

	start is
		do
			file_names.start
			tradable_factories.start
		end

	finish is
		do
			file_names.finish
			tradable_factories.finish
		end

	forth is
		do
			file_names.forth
			tradable_factories.forth
		end

feature {FACTORY} -- Access

	tradable_factories: LINEAR [TRADABLE_FACTORY]
			-- Manufacturers of tradables - one for each element of filenames

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

	cached_item (i: INTEGER): TRADABLE [BASIC_MARKET_TUPLE] is
			-- The cached item with index `i' - Void if not in cache
		do
			from
				cache.start
			until
				cache.exhausted or else cache.item.right = i
			loop
				cache.forth
			end
			if not cache.exhausted then
				Result := cache.item.left
			end
		ensure
			correct_result:
				not cache.exhausted implies (Result = cache.item.left)
			void_if_not_there: cache.exhausted implies Result = Void
		end

	add_to_cache (t: TRADABLE [BASIC_MARKET_TUPLE]; idx: INTEGER) is
			-- Add `t' with its `idx' to the cache
		require
			not_void: t /= Void
		local
			pair: PAIR [TRADABLE [BASIC_MARKET_TUPLE], INTEGER]
		do
			if cache.count = cache_size then
				-- Arbitrarily prune the last item to keep within the
				-- allowed cache size.
				cache.prune (cache.last)
			end
			!!pair.make (t, index)
			cache.extend (pair)
		end

	open_current_file: PLAIN_TEXT_FILE is
			-- Open the file associated with `file_names'.item.
			-- If the open fails with an exception, print an error message,
			-- set Result to Void, and allow the exception to propogate.
		do
			!!Result.make_open_read (file_names.item)
		rescue
			print ("Failed to open file ") print (file_names.item)
			print ("%N")
			Result := Void
		end

	cache_size: INTEGER
			-- The maximum size for the cache

	cache: LIST [PAIR [TRADABLE [BASIC_MARKET_TUPLE], INTEGER]]
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

	fn_tf_not_void: file_names /= Void and tradable_factories /= Void
	always_compare_objects: object_comparison = true
	index_definition: index = file_names.index
	cache_not_too_large: cache.count <= cache_size

end -- class VIRTUAL_TRADABLE_LIST
