indexing
	description: "Factory class that manufactures TRADABLEs"
	note: "input must be set (non-Void) before execute is called."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class TRADABLE_FACTORY inherit

	FACTORY
		redefine
			product
		end

	TRADABLE_FACTORY_CONSTANTS
		export
			{NONE} all
		end

	GLOBAL_SERVICES
		export {NONE}
			all
		end

	GLOBAL_APPLICATION
		export {NONE}
			all
		end

creation

	make

feature -- Initialization

	make is
		do
			field_separator := "%T"
			record_separator := "%N"
			time_period_type := period_types @ (period_type_names @ Daily)
			create stock_builder
			create derivative_builder
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

	tuple_maker: BASIC_TUPLE_FACTORY
			-- Factory to create the appropriate type of tuples

	field_separator: STRING
			-- Field separator to expect while scanning input

	record_separator: STRING
			-- Record separator to expect while scanning input

	time_period_type: TIME_PERIOD_TYPE
			-- The period type, such as daily, that will be assigned
			-- to the manufactured tradable

feature -- Status report

	error_occurred: BOOLEAN
			-- Did an error occur during execute?

	last_error_fatal: BOOLEAN
			-- Was the last error unrecoverable?

	strict_error_checking: BOOLEAN

	error_list: LIST [STRING]
			-- List of all errors if error_occurred

	intraday: BOOLEAN
			-- Is a tradable with intraday data being created?

feature -- Status setting

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
			-- arg contains no upper-case characters
		do
			symbol := arg
		ensure
			symbol_set: symbol /= Void and symbol = arg
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

	set_strict_error_checking (arg: BOOLEAN) is
			-- Set strict_error_checking to `arg'.
		do
			strict_error_checking := arg
		ensure
			strict_error_checking_set: strict_error_checking = arg
		end

	set_intraday (arg: BOOLEAN) is
			-- Set intraday to `arg'.
		do
			intraday := arg
		ensure
			intraday_set: intraday = arg
		end

feature -- Basic operations

	execute is
			-- Note: Once `execute' is called, set_intraday will have no
			-- effect - the tradable's data will be intraday according to
			-- the value of `intraday' the first time that execute is called.
		local
			scanner: MARKET_TUPLE_DATA_SCANNER
			intraday_scanner: INTRADAY_TUPLE_DATA_SCANNER
		do
			error_occurred := False
			check_for_open_interest
			make_product
			make_tuple_maker
			if intraday then
				create intraday_scanner.make (
					product, input, tuple_maker, value_setters)
				scanner := intraday_scanner
			else
				create scanner.make (product, input, tuple_maker, value_setters)
			end
			scanner.set_strict_error_checking (strict_error_checking)
			-- Input data from input stream and stuff it into product.
			scanner.execute
			check
				product_set_to_scanner_result: product = scanner.product
			end
			if not scanner.error_list.is_empty then
				error_list := scanner.error_list
				error_occurred := True
				last_error_fatal := scanner.last_error_fatal
			end
			if intraday then
				time_period_type := intraday_scanner.period_type
				if time_period_type = Void then -- empty input data
					time_period_type := period_types @ (
						period_type_names @ Hourly)
				end
			end
			check
				period_type_not_greater_than_day:
					not time_period_type.intraday implies time_period_type =
					period_types @ (period_type_names @ Daily)
			end
			product.set_trading_period_type (time_period_type)
			product.finish_loading
			add_indicators (product)
		ensure then
			product_not_void: product /= Void
			product_type_set: product.trading_period_type = time_period_type
		end

feature {NONE}

	make_product is
		do
			if open_interest then
				product := derivative_builder.new_item (symbol)
			else
				product := stock_builder.new_item (symbol)
			end
		ensure
			not_vod: product /= Void
		end

feature {NONE} -- Implementation

	stock_builder: STOCK_BUILDING_UTILITIES

	derivative_builder: DERIVATIVE_BUILDING_UTILITIES

	make_tuple_maker is
		do
			if open_interest then
				tuple_maker := derivative_builder.tuple_factory
			else
				tuple_maker := stock_builder.tuple_factory
			end
		ensure
			tm_not_void: tuple_maker /= Void
		end

	index_vector: ARRAY [INTEGER] is
			-- Index vector for value setters
		do
			if open_interest then
				Result := derivative_builder.index_vector (intraday)
			else
				Result := stock_builder.index_vector (intraday)
			end
		ensure
			at_least_one: Result.count > 0
		end

	value_setters: LINKED_LIST [VALUE_SETTER] is
		do
			if
				cached_value_setters = Void or
				old_open_interest_setting /= open_interest
			then
				old_open_interest_setting := open_interest
				create cached_value_setters.make
				add_value_setters (cached_value_setters, index_vector)
			end
			Result := cached_value_setters
		ensure
			at_least_one: Result.count > 0
		end

	add_value_setters (vs: LINKED_LIST [VALUE_SETTER];
						i_vector: ARRAY [INTEGER]) is
			-- i_vector indicates which value_setters to insert into
			-- vs, in the order specified, using the xxx_index constants.
			-- For example, i_vector = << Date_index, Close_index >>
			-- specifies to insert the DATE_SETTER, then the CLOSE_SETTER.
		require
			vs /= Void
		local
			value_setter_vector: ARRAY [VALUE_SETTER]
			setter: VALUE_SETTER
			i: INTEGER
			gsf: expanded GLOBAL_SERVER_FACILITIES
		do
			if value_setter_vector = Void then
				create value_setter_vector.make (1, Last_index)
				create {DATE_SETTER} setter.make
				value_setter_vector.put (setter, Date_index)
				create {CONFIGURABLE_DATE_SETTER} setter.make (
					gsf.command_line_options.special_date_settings)
				value_setter_vector.put (setter, Configurable_date_index)
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

	add_indicators (t: TRADABLE [BASIC_MARKET_TUPLE]) is
			-- Add `flst' to `t'.
		require
			not_void: t /= Void
		local
			flst: LIST [MARKET_FUNCTION]
		do
			if open_interest then
				-- t is a derivative instrument - all functions are valid,
				-- so set flst to `function_library'.
				flst := function_library
			else
				-- t is a stock - use only valid stock functions.
				flst := stock_function_library
			end
			check flst /= Void end
			from
				flst.start
			until
				flst.after
			loop
				t.add_indicator (flst.item)
				flst.forth
			end
		end

	cached_value_setters: LINKED_LIST [VALUE_SETTER]

	check_for_open_interest is
			-- Check if `input' has an open interest field.
		require
			input_not_void: input /= Void
		local
			expected_fields: INTEGER
			gsf: expanded GLOBAL_SERVER_FACILITIES
		do
			expected_fields := 6
			if gsf.command_line_options.opening_price then
				expected_fields := expected_fields + 1
			end
			if intraday then
				expected_fields := expected_fields + 1
			end
			open_interest := input.field_count = expected_fields
		end

	open_interest: BOOLEAN
			-- Is there an open interest field in the input?

	old_open_interest_setting: BOOLEAN
			-- Previous state of `open_interest'

invariant

	these_fields_not_void:
		field_separator /= Void and
		record_separator /= Void and
		time_period_type /= Void
	error_constraint:
		error_occurred implies error_list /= Void and not error_list.is_empty
	builders_not_void: stock_builder /= Void and derivative_builder /= Void

end -- TRADABLE_FACTORY
