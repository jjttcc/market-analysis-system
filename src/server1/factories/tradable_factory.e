note
	description: "Factory class that manufactures TRADABLEs"
	note1: "input must be set (non-Void) before execute is called."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class TRADABLE_FACTORY inherit

	GENERIC_FACTORY [TRADABLE[BASIC_TRADABLE_TUPLE]]
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

	make
		do
			field_separator := "%T"
			record_separator := "%N"
			time_period_type := period_types @ (period_type_names @ Daily)
			create stock_builder
			create derivative_builder
			start_input_from_beginning := True
			-- Fulfill a mysterious assertion (unhelpful IDE):
			create {STOCK} product.make ("ibm", Void, Void)
		ensure
			daily_type: time_period_type.name.is_equal (
				period_type_names @ Daily)
			fs_tab: field_separator.is_equal ("%T")
			rs_newline: record_separator.is_equal ("%N")
			non_strict: strict_error_checking = False
			start_input_from_beginning: start_input_from_beginning
		end

feature -- Access

	product: TRADABLE [BASIC_TRADABLE_TUPLE]
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

	start_input_from_beginning: BOOLEAN
			-- Is 'input.start' to be called by `execute' before
			-- scanning the data?

feature -- Status setting

	set_input (arg: like input)
			-- Set input to `arg'.
		require
			open_for_reading: arg /= Void
		do
			input := arg
		ensure
			input_set: input = arg and input /= Void
		end

	set_symbol (arg: STRING)
			-- Set symbol to `arg'.
		require
			arg_not_void: arg /= Void
			-- arg contains no upper-case characters
		do
			symbol := arg
		ensure
			symbol_set: symbol /= Void and symbol = arg
		end

	set_product (arg: TRADABLE [BASIC_TRADABLE_TUPLE])
			-- Set `product' to `arg', to be updated by `execute' instead
			-- of creating a new product.
		require
			arg_not_void: arg /= Void
		do
			product := arg
			update_current_product := True
		ensure
			product_set: product = arg and product /= Void
			update_current_product: update_current_product
		end

	set_time_period_type (arg: TIME_PERIOD_TYPE)
			-- Set time_period_type to `arg'.
		require
			arg_not_void: arg /= Void
		do
			time_period_type := arg
		ensure
			time_period_type_set: time_period_type = arg and
				time_period_type /= Void
		end

	set_field_separator (arg: STRING)
			-- Set field_separator to `arg'.
		require
			arg_not_void: arg /= Void
		do
			field_separator := arg
		ensure
			field_separator_set: field_separator = arg and
				field_separator /= Void
		end

	set_record_separator (arg: STRING)
			-- Set record_separator to `arg'.
		require
			arg_not_void: arg /= Void
		do
			record_separator := arg
		ensure
			record_separator_set: record_separator = arg and
				record_separator /= Void
		end

	set_strict_error_checking (arg: BOOLEAN)
			-- Set strict_error_checking to `arg'.
		do
			strict_error_checking := arg
		ensure
			strict_error_checking_set: strict_error_checking = arg
		end

	set_intraday (arg: BOOLEAN)
			-- Set intraday to `arg'.
		do
			intraday := arg
		ensure
			intraday_set: intraday = arg
		end

	turn_start_input_from_beginning_off
			-- Set `start_input_from_beginning' to False.
		do
			start_input_from_beginning := False
		ensure
			not_start_input_from_beginning: not start_input_from_beginning
		end

	turn_start_input_from_beginning_on
			-- Set `start_input_from_beginning' to True.
		do
			start_input_from_beginning := True
		ensure
			start_input_from_beginning: start_input_from_beginning
		end

feature -- Basic operations

	execute
			-- Note: Once `execute' is called, set_intraday will have no
			-- effect - the tradable's data will be intraday according to
			-- the value of `intraday' the first time that execute is called.
		local
			scanner: TRADABLE_TUPLE_DATA_SCANNER
			intraday_scanner: INTRADAY_TUPLE_DATA_SCANNER
		do
			error_occurred := False
			check_for_open_interest
			if not update_current_product then
				make_product
			else
			end
			check
				product_exists:  product /= Void
			end
			make_tuple_maker
			if intraday then
				create intraday_scanner.make (product, input, tuple_maker,
					value_setters)
				scanner := intraday_scanner
			else
				create scanner.make (product, input, tuple_maker, value_setters)
			end
			scanner.set_strict_error_checking (strict_error_checking)
			if not start_input_from_beginning then
				scanner.turn_start_input_off
			end
			check
				correct_input_start_status:
					scanner.start_input = start_input_from_beginning
			end
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
			if intraday and start_input_from_beginning then
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
			-- (Don't set the period type if data is being appended.)
			if start_input_from_beginning then
				product.set_trading_period_type (time_period_type)
			end
			product.finish_loading
			-- If `update_current_product', the product's indicators have
			-- already been set up.
			if not update_current_product then
				add_indicators (product)
			end
			update_current_product := False
		ensure then
			product_not_void: product /= Void
			product_type_set: product.trading_period_type = time_period_type
			no_current_update: update_current_product = False
			old_product_count_smaller_or_equal_if_update_current:
				old update_current_product implies
				old product.count <= product.count
		end

feature {NONE}

	make_product
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

	update_current_product: BOOLEAN
			-- Should the current `product' be updated by `execute' rather
			-- than created a new one?

	make_tuple_maker
		do
			if open_interest then
				tuple_maker := derivative_builder.tuple_factory
			else
				tuple_maker := stock_builder.tuple_factory
			end
		ensure
			tm_not_void: tuple_maker /= Void
		end

	index_vector: ARRAYED_LIST [INTEGER]
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

	value_setters: LINKED_LIST [VALUE_SETTER [BASIC_TRADABLE_TUPLE]]
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

	add_value_setters (vs: LINKED_LIST [VALUE_SETTER [TRADABLE_TUPLE]];
						i_vector: ARRAYED_LIST [INTEGER])
			-- i_vector indicates which value_setters to insert into
			-- vs, in the order specified, using the xxx_index constants.
			-- For example, i_vector = << Date_index, Close_index >>
			-- specifies to insert the DATE_SETTER, then the CLOSE_SETTER.
		require
			vs /= Void
		local
--			value_setter_vector: ARRAY [VALUE_SETTER [BASIC_TRADABLE_TUPLE]]
			value_setter_vector: ARRAY [VALUE_SETTER [TRADABLE_TUPLE]]
			date_setter: DATE_SETTER
			configurable_date_setter: CONFIGURABLE_DATE_SETTER
			time_setter: TIME_SETTER
			open_setter: OPEN_SETTER
			high_setter: HIGH_SETTER
			low_setter: LOW_SETTER
			close_setter: CLOSE_SETTER
			volume_setter: VOLUME_SETTER
			open_interest_setter: OPEN_INTEREST_SETTER
			i: INTEGER
			gsf: expanded GLOBAL_SERVER_FACILITIES
		do
			if value_setter_vector = Void then
				create value_setter_vector.make_empty
				create date_setter.make
				value_setter_vector.force (date_setter, Date_index)
				create configurable_date_setter.make (
					gsf.command_line_options.special_date_settings)
				value_setter_vector.force (configurable_date_setter,
					Configurable_date_index)
				create time_setter.make
				value_setter_vector.force (time_setter, Time_index)
				create open_setter
				value_setter_vector.force (open_setter, Open_index)
				create high_setter
				value_setter_vector.force (high_setter, High_index)
				create low_setter
				value_setter_vector.force (low_setter, Low_index)
				create close_setter
				value_setter_vector.force (close_setter, Close_index)
				create volume_setter.make
				value_setter_vector.force (volume_setter, Volume_index)
				create open_interest_setter
				value_setter_vector.force (open_interest_setter, OI_index)
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

	add_indicators (t: TRADABLE [BASIC_TRADABLE_TUPLE])
			-- Add `flst' to `t'.
		require
			not_void: t /= Void
		local
			flst: LIST [TRADABLE_FUNCTION]
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

	cached_value_setters: LINKED_LIST [VALUE_SETTER [BASIC_TRADABLE_TUPLE]]

	check_for_open_interest
			-- Check if `input' has an open interest field.
		require
			input_not_void: input /= Void
		local
			expected_fields: INTEGER
			gsf: expanded GLOBAL_SERVER_FACILITIES
		do
			if update_current_product then
				open_interest := product.has_open_interest
			else
				expected_fields := date_ohlc_vol_field_count
				if gsf.command_line_options.opening_price then
					expected_fields := expected_fields + 1
				end
				if intraday then
					expected_fields := expected_fields + 1
				end
				open_interest := input.field_count = expected_fields
			end
		end

	open_interest: BOOLEAN
			-- Is there an open interest field in the input?

	old_open_interest_setting: BOOLEAN
			-- Previous state of `open_interest'

invariant

	these_fields_not_void: field_separator /= Void and
		record_separator /= Void and time_period_type /= Void
	error_constraint:
		error_occurred implies error_list /= Void and not error_list.is_empty
	builders_not_void: stock_builder /= Void and derivative_builder /= Void
	product_exists_if_using_current:
		update_current_product implies product /= Void

end -- TRADABLE_FACTORY
