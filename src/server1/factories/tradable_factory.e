indexing
	description: "Factory class that manufactures TRADABLEs"
	note: "input must be set (non-Void) before execute is called."
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class TRADABLE_FACTORY inherit

	FACTORY
		redefine
			product
		end

	GLOBAL_SERVICES
		export {NONE}
			all
		end

feature -- Initialization

	make is
		do
			field_separator := "%T"
			record_separator := "%N"
			time_period_type := period_types @ (period_type_names @ Daily)
		ensure
			daily_type: time_period_type.name.is_equal (
				period_type_names @ Daily)
			fs_tab: field_separator.is_equal ("%T")
			rs_newline: record_separator.is_equal ("%N")
			non_strict: strict_error_checking = false
		end

feature -- Access

	product: TRADABLE [BASIC_MARKET_TUPLE]
			-- Result of execution

	input: INPUT_RECORD_SEQUENCE
			-- Input sequence containing data to be scanned into tuples

	symbol: STRING
			-- Symbol to give the newly created tradable

	tuple_maker: BASIC_TUPLE_FACTORY is
			-- Factory to create the appropriate type of tuples
		deferred
		end

	field_separator: STRING
			-- Field separator to expect while scanning input

	record_separator: STRING
			-- Record separator to expect while scanning input

	time_period_type: TIME_PERIOD_TYPE
			-- The period type, such as daily, that will be assigned
			-- to the manufactured tradable

	indicators: LIST [MARKET_FUNCTION]
			-- List of TA indicators to provide to the tradable

feature -- Status report

	no_open: BOOLEAN
			-- Is there no opening price field in the input?

	error_occurred: BOOLEAN
			-- Did an error occur during execute?

	strict_error_checking: BOOLEAN

	error_list: LIST [STRING]
			-- List of all errors if error_occurred

feature -- Status setting

	set_no_open (arg: BOOLEAN) is
			-- Set no_open to `arg'.
		do
			no_open := arg
		ensure
			no_open_set: no_open = arg
		end

	set_input (arg: like input) is
			-- Set input to `arg'.
		require
			open_for_reading: arg /= Void
		do
			input := arg
		ensure
			input_set: input = arg and input /= Void
		end

	set_symbol (arg: STRING) is
			-- Set symbol to `arg'.
		require
			arg_not_void: arg /= Void
		do
			symbol := arg
		ensure
			symbol_set: symbol = arg and symbol /= Void
		end

	set_time_period_type (arg: TIME_PERIOD_TYPE) is
			-- Set time_period_type to `arg'.
		require
			arg_not_void: arg /= Void
		do
			time_period_type := arg
		ensure
			time_period_type_set: time_period_type = arg and
				time_period_type /= Void
		end

	set_field_separator (arg: STRING) is
			-- Set field_separator to `arg'.
		require
			arg_not_void: arg /= Void
		do
			field_separator := arg
		ensure
			field_separator_set: field_separator = arg and
				field_separator /= Void
		end

	set_record_separator (arg: STRING) is
			-- Set record_separator to `arg'.
		require
			arg_not_void: arg /= Void
		do
			record_separator := arg
		ensure
			record_separator_set: record_separator = arg and
				record_separator /= Void
		end

	set_indicators (arg: LIST [MARKET_FUNCTION]) is
			-- Set indicators to `arg'.
		require
			arg_not_void: arg /= Void
		do
			indicators := arg
		ensure
			indicators_set: indicators = arg and indicators /= Void
		end

	set_strict_error_checking (arg: BOOLEAN) is
			-- Set strict_error_checking to `arg'.
		do
			strict_error_checking := arg
		ensure
			strict_error_checking_set: strict_error_checking = arg
		end

feature -- Basic operations

	execute is
		local
			scanner: MARKET_TUPLE_DATA_SCANNER
		do
			error_occurred := False
			make_product
			check value_setters.count > 0 end
			create scanner.make (product, input, tuple_maker, value_setters)
			scanner.set_strict_error_checking (strict_error_checking)
			-- Input data from input stream and stuff it into product.
			scanner.execute
			add_indicators (product, indicators)
			check
				product_set_to_scanner_result: product = scanner.product
			end
			if not scanner.error_list.empty then
				error_list := scanner.error_list
				error_occurred := True
			end
			product.finish_loading
		ensure then
			product_not_void: product /= Void
			product_type_set: product.trading_period_type = time_period_type
		end

feature {NONE}

	make_product is
		deferred
		ensure
			not_vod: product /= Void
		end

feature {NONE} -- Implementation

	index_vector: ARRAY [INTEGER] is
			-- To be defined by descendants to specify desired field order.
		deferred
		end

	value_setters: LINKED_LIST [VALUE_SETTER] is
		once
			create Result.make
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
				create value_setter_vector.make (1, Last_index)
				create {DAY_DATE_SETTER} setter.make
				value_setter_vector.put (setter, Date_index)
				create {TIME_SETTER} setter.make
				value_setter_vector.put (setter, Time_index)
				create {OPEN_SETTER} setter
				value_setter_vector.put (setter, Open_index)
				create {HIGH_SETTER} setter
				value_setter_vector.put (setter, High_index)
				create {LOW_SETTER} setter
				value_setter_vector.put (setter, Low_index)
				create {CLOSE_SETTER} setter
				value_setter_vector.put (setter, Close_index)
				create {VOLUME_SETTER} setter.make
				value_setter_vector.put (setter, Volume_index)
				create {OPEN_INTEREST_SETTER} setter
				value_setter_vector.put (setter, OI_index)
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

	add_indicators (t: TRADABLE [BASIC_MARKET_TUPLE];
					flst: LIST [MARKET_FUNCTION]) is
			-- Add `flst' to `t'.
		require
			not_void: t /= Void and flst /= Void
		do
			from
				flst.start
			until
				flst.after
			loop
				t.add_indicator (flst.item)
				flst.forth
			end
		end

feature {NONE} -- Tuple field-key constants

	Date_index: INTEGER is 1
	Time_index: INTEGER is 2
	Open_index: INTEGER is 3
	High_index: INTEGER is 4
	Low_index: INTEGER is 5
	Close_index: INTEGER is 6
	Volume_index: INTEGER is 7
	OI_index: INTEGER is 8
	Last_index: INTEGER is 8

invariant

	these_fields_not_void:
		field_separator /= Void and
		record_separator /= Void and
		tuple_maker /= Void and time_period_type /= Void
	error_constraint:
		error_occurred implies error_list /= Void and not error_list.empty

end -- TRADABLE_FACTORY
