indexing
	description: "Factory class that manufactures TRADABLEs"
	date: "$Date$";
	revision: "$Revision$"

deferred class TRADABLE_FACTORY inherit

	FACTORY
		redefine
			product
		end

	GLOBAL_SERVICES

feature -- Initialization

	make (in_file: FILE) is
		require
			open_for_reading: in_file /= Void and in_file.exists and
								in_file.is_open_read
		do
			field_separator := "%T"
			input_file := in_file
			time_period_type := period_types @ "daily"
		ensure
			daily_type: time_period_type.name.is_equal ("daily")
			fs_tab: field_separator.is_equal ("%T")
			set: input_file = in_file and input_file /= Void
		end

feature -- Access

	product: TRADABLE [BASIC_MARKET_TUPLE]
			-- Result of execution

	input_file: FILE
			-- File containing data to be scanned into tuples

	tuple_maker: BASIC_TUPLE_FACTORY is
			-- Factory to create the appropriate type of tuples
		deferred
		end

	field_separator: STRING
			-- Field separator to expect while scanning input_file

	time_period_type: TIME_PERIOD_TYPE
			-- The period type, such as daily, that will be assigned
			-- to the manufactured tradable

feature -- Status report

	no_open: BOOLEAN
			-- Is there no opening price field in the input?

	arg_used: BOOLEAN is false
			-- execute arg is actually optional - if not void it is used.

feature -- Status setting

	set_no_open (arg: BOOLEAN) is
			-- Set no_open to `arg'.
		require
			arg /= Void
		do
			no_open := arg
		ensure
			no_open_set: no_open = arg and no_open /= Void
		end

feature -- Basic operations

	execute (in_file: FILE) is
			-- If in_file is not void and is open for reading, it will
			-- be used for input instead of what passed to make.
		local
			scanner: MARKET_TUPLE_DATA_SCANNER
		do
			if
				in_file /= Void and in_file.exists and in_file.is_open_read
			then
				input_file := in_file
			end
			make_product
			check value_setters.count > 0 end
			!!scanner.make (product, input_file, tuple_maker, value_setters)
			if not scanner.field_separator.is_equal (field_separator) then
				scanner.set_field_separator (field_separator)
			end
			-- Input data from input_file and stuff it into product.
			scanner.execute (Void)
			check
				product_set_to_scanner_result: product = scanner.product
			end
			-- Create a bunch of market functions and insert them into product.
			add_indicators (product)
		ensure then
			product_not_void: product /= Void
			product_type_set: product.trading_period_type = time_period_type
		end

feature -- Element change

	set_input_file (arg: FILE) is
			-- Set input_file to `arg'.
		require
			arg /= Void
		do
			input_file := arg
		ensure
			input_file_set: input_file = arg and input_file /= Void
		end

	set_time_period_type (arg: TIME_PERIOD_TYPE) is
			-- Set time_period_type to `arg'.
		require
			arg /= Void
		do
			time_period_type := arg
		ensure
			time_period_type_set: time_period_type = arg and
				time_period_type /= Void
		end

	set_field_separator (arg: STRING) is
			-- Set field_separator to `arg'.
		require
			arg /= Void
		do
			field_separator := arg
		ensure
			field_separator_set: field_separator = arg and
				field_separator /= Void
		end

feature {NONE}

	make_product is
		deferred
		ensure
			not_vod: product /= Void
		end

feature {NONE} -- Scanning-related utility features

	index_vector: ARRAY [INTEGER] is
			-- To be defined by descendants to specify desired field order.
		deferred
		end

	value_setters: LINKED_LIST [VALUE_SETTER] is
		once
			!!Result.make
			add_value_setters (Result, index_vector)
		end

	add_value_setters (vs: LINKED_LIST [VALUE_SETTER];
						i_vector: ARRAY [INTEGER]) is
			-- i_vector indicates which value_setters to insert into
			-- vs, in the order specified, using the xxx_index constants.
			-- For example, i_vector = << Date_index, Close_index >>
			-- specifies to insert the DAY_DATE_SETTER, then the CLOSE_SETTER.
		require
			vs /= Void
		local
			value_setter_vector: ARRAY [VALUE_SETTER]
			setter: VALUE_SETTER
			i: INTEGER
		do
			if value_setter_vector = Void then
				i := 1
				!!value_setter_vector.make (1, 7)
				!DAY_DATE_SETTER!setter.make
				value_setter_vector.put (setter, i)
				i := i + 1
				!OPEN_SETTER!setter
				value_setter_vector.put (setter, i)
				i := i + 1
				!HIGH_SETTER!setter
				value_setter_vector.put (setter, i)
				i := i + 1
				!LOW_SETTER!setter
				value_setter_vector.put (setter, i)
				i := i + 1
				!CLOSE_SETTER!setter
				value_setter_vector.put (setter, i)
				i := i + 1
				!VOLUME_SETTER!setter.make
				value_setter_vector.put (setter, i)
				i := i + 1
				!OPEN_INTEREST_SETTER!setter
				value_setter_vector.put (setter, i)
			end
			from
				i := 1
			until
				i = i_vector.count + 1
			loop
				vs.extend (value_setter_vector @ (i_vector @ i))
				i := i + 1
			end
		end

feature {NONE}

	add_indicators (t: TRADABLE [BASIC_MARKET_TUPLE]) is
			-- Add hard-coded set of market functions to `t'.
		do
		end

feature {NONE} -- Tuple field-key constants

	Date_index: INTEGER is 1
	Open_index: INTEGER is 2
	High_index: INTEGER is 3
	Low_index: INTEGER is 4
	Close_index: INTEGER is 5
	Volume_index: INTEGER is 6
	OI_index: INTEGER is 7

invariant

	these_fields_not_void:
		field_separator /= Void and input_file /= Void and
		tuple_maker /= Void and time_period_type /= Void

end -- TRADABLE_FACTORY
