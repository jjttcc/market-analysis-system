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
		ensure
			set: file_names = filenames and tradable_factories = factories
			implementation_init: last_tradable = Void and old_index = 0
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
			-- Create a new tradable only if the cursor has moved since
			-- the last tradable creation
			if file_names.index /= old_index then
				!!input_file.make_open_read (file_names.item)
				tradable_factories.item.set_input_file (input_file)
				tradable_factories.item.execute
				last_tradable := tradable_factories.item.product
				if tradable_factories.item.error_occurred then
					print_errors (last_tradable,
									tradable_factories.item.error_list)
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

end -- class VIRTUAL_TRADABLE_LIST
