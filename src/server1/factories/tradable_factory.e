indexing
	description: "Factory class that manufactures TRADABLEs"
	date: "$Date$";
	revision: "$Revision$"

deferred class TRADABLE_FACTORY inherit

	FACTORY
		redefine
			product
		end

feature -- Initialization

	make (in_file: PLAIN_TEXT_FILE) is
		require
			not_void: in_file /= Void and in_file.exists and
						in_file.is_open_read
		do
			field_separator := "%T"
			input_file := in_file
		ensure
			fs_tab: field_separator.is_equal ("%T")
			set: input_file = in_file and input_file /= Void
		end

feature -- Basic operations

	execute (arg: ANY) is
		local
			scanner: MARKET_TUPLE_DATA_SCANNER
		do
			make_product
			check value_setters.count > 0 end
			!!scanner.make (input_file, tuple_maker, value_setters,
			 				field_separator, "%N")
			-- Input data from input_file and stuff it into product.
			scanner.set_product_instance (product)
			scanner.execute (Void)
			product := scanner.product
			-- Create a bunch of market functions and insert them into product.
			add_indicators (product)
		end

feature -- Status report

	no_open: BOOLEAN
			-- Is there no opening price field in the input?

	arg_used: BOOLEAN is false

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

feature {NONE} -- Hard-coded market function building procedures

	create_macd (f1, f2: EXPONENTIAL_MOVING_AVERAGE): MARKET_FUNCTION is
			-- Create an MACD function using `f1' and `f2'.
		require
			not_void: f1 /= Void and f2 /= Void
			-- !!!Is this precondition reasonable?:
			o_not_void: f1.output /= Void and f2.output /= Void
		local
			sub: SUBTRACTION
			cmd1: BASIC_LINEAR_COMMAND
			cmd2: BASIC_LINEAR_COMMAND
		do
			!!cmd1.make (f1.output)
			!!cmd2.make (f2.output)
			!!sub.make_with_operands (cmd1, cmd2)
			!TWO_VARIABLE_FUNCTION!Result.make (f1, f2, sub)
			Result.set_name ("MACD difference")
		ensure
			not_void: Result /= Void
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
		field_separator /= Void and input_file /= Void and tuple_maker /= Void

end -- TRADABLE_FACTORY
