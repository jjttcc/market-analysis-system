indexing
	description:
		"STOCK_SPLITS implemented as an INPUT_RECORD_SEQUENCE"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class STOCK_SPLIT_SEQUENCE inherit

	STOCK_SPLITS

	INPUT_RECORD_SEQUENCE

	DATA_SCANNER
		rename
			make as ds_make_unused
		export
			{NONE} all
		redefine
			close_tuple, product, tuple_maker, add_tuple
		end

feature -- Access

	infix "@" (symbol: STRING): DYNAMIC_CHAIN [STOCK_SPLIT] is
		do
			product.search (symbol)
			if product.found then
				Result := product.found_item
			end
		end

feature {NONE} -- Initialization

	make is
		require
			product_created: product /= Void
		do
			create tuple_maker
			make_value_setters
			input := Current
			execute
		ensure
			input_set: input = Current
			value_setters_made: value_setters /= Void
			tuple_maker_made: tuple_maker /= Void
		end

feature {SPLIT_SYMBOL_SETTER} -- Implementation - access

	set_current_symbol (arg: STRING) is
			-- Set current_symbol to `arg'.
		require
			arg_not_void: arg /= Void
		do
			current_symbol := arg
		ensure
			current_symbol_set: current_symbol = arg and
				current_symbol /= Void
		end

feature {NONE} -- Implementation - access

	current_symbol: STRING
			-- Symbol for split currently being scanned

	tuple_maker: STOCK_SPLIT_FACTORY

	product: HASH_TABLE [DYNAMIC_CHAIN [STOCK_SPLIT], STRING]

feature {NONE} -- Implementation - utility

	index_vector: ARRAY [INTEGER] is
		once
			Result := <<Date_index, Symbol_index, Split_index>>
		end

	make_value_setters is
		do
			create {LINKED_LIST [VALUE_SETTER]} value_setters.make
			add_value_setters (value_setters, index_vector)
		end

	add_value_setters (vs: LIST [VALUE_SETTER];
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
			create value_setter_vector.make (1, Last_index)
			create {DAY_DATE_SETTER} setter.make
			value_setter_vector.put (setter, Date_index)
			create {SPLIT_SYMBOL_SETTER} setter.make (Current)
			value_setter_vector.put (setter, Symbol_index)
			create {SPLIT_SETTER} setter
			value_setter_vector.put (setter, Split_index)
			from
				i := 1
			until
				i = i_vector.count + 1
			loop
				vs.extend (value_setter_vector @ (i_vector @ i))
				i := i + 1
			end
		end

feature {NONE} -- Implementation - hooks

	close_tuple (t: STOCK_SPLIT) is
			-- Add the new tuple to the list at `product' @ `current_symbol',
			-- with `current_symbol' converted to lower case; create a
			-- list and place it into `product' if not
			-- product.has (current_symbol)
		local
			l: DYNAMIC_CHAIN [STOCK_SPLIT]
		do
			current_symbol.to_lower
			if not product.has (current_symbol) then
				create {LINKED_LIST [STOCK_SPLIT]} l.make
				product.put (l, clone (current_symbol))
			else
				l := product @ current_symbol
			end
			l.extend (t)
		ensure then
			tuple_in_product: product.has (current_symbol) and
				(product @ current_symbol).has (t)
		end

feature {NONE} -- Innapplicable

	create_product is
		do
		end

	add_tuple (t: ANY) is
		do
		end

feature {NONE} -- Tuple field-key constants

	Date_index: INTEGER is 1
	Symbol_index: INTEGER is 2
	Split_index: INTEGER is 3
	Last_index: INTEGER is 3

invariant

	these_fields_not_void:
		tuple_maker /= Void and value_setters /= Void and product /= Void

end -- STOCK_SPLIT_SEQUENCE
