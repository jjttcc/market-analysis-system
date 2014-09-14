note
	description:
		"STOCK_SPLITS implemented as an INPUT_RECORD_SEQUENCE"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class STOCK_SPLIT_SEQUENCE inherit

	STOCK_SPLITS

	INPUT_RECORD_SEQUENCE

	DATA_SCANNER [STOCK_SPLIT]
		rename
			make as ds_make_unused
		export
			{NONE} all
		redefine
			close_tuple, product, tuple_maker, add_tuple, set_tuple_maker
		end

	EXCEPTION_SERVICES
		export
--			{NONE} all
		end

feature -- Access

	infix "@" (symbol: STRING): DYNAMIC_CHAIN [STOCK_SPLIT]
		do
			product.search (symbol)
			if product.found then
				Result := product.found_item
			end
		end

	product_count: INTEGER do Result := product.count end

feature -- Element change

--!!!!!!!!!????????[14.05]:
--!!!!Test stock splits to verify that this change is good:
--	set_tuple_maker (arg: FACTORY[STOCK_SPLIT])
	set_tuple_maker (arg: STOCK_SPLIT_FACTORY)
			-- Set tuple_maker to `arg'.
		do
			if attached {STOCK_SPLIT_FACTORY} arg as ssf then
				tuple_maker := ssf
			else
				raise ("cast of " + arg.generating_type + " failed " +
					"in STOCK_SPLIT_SEQUENCE, line 46")
			end
		end

feature {NONE} -- Initialization

	make
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

	set_current_symbol (arg: STRING)
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

--	tuple_maker: FACTORY [STOCK_SPLIT]
--	tuple_maker: FACTORY [DYNAMIC_CHAIN [STOCK_SPLIT]]
--!!!!Test stock splits to verify that this change is good:
	tuple_maker: STOCK_SPLIT_FACTORY

--	product: HASH_TABLE [STOCK_SPLIT, STRING]
--!!!!Test stock splits to verify that this change is good:
	product: HASH_TABLE [DYNAMIC_CHAIN [STOCK_SPLIT], STRING]

feature {NONE} -- Implementation - utility

	index_vector: ARRAY [INTEGER]
		note
			once_status: global
		once
			Result := <<Date_index, Symbol_index, Split_index>>
		end

	make_value_setters
		do
--!!!!!!FIX!!!!!(Does it need fixing?):
			create {LINKED_LIST [VALUE_SETTER [STOCK_SPLIT]]} value_setters.make
--!!!!!!FIX!!!!!(Does it need fixing?):
			add_value_setters (value_setters, index_vector)
		end

	add_value_setters (vs: LIST [VALUE_SETTER [TRADABLE_TUPLE]];
						i_vector: ARRAY [INTEGER])
			-- i_vector indicates which value_setters to insert into
			-- vs, in the order specified, using the xxx_index constants.
		require
			vs /= Void
		local
			value_setter_vector: ARRAY [VALUE_SETTER [TRADABLE_TUPLE]]
			date_setter: DATE_SETTER
			splitsym_setter: SPLIT_SYMBOL_SETTER
			split_setter: SPLIT_SETTER
			i: INTEGER
		do
			create value_setter_vector.make_empty
			create date_setter.make
			value_setter_vector.force (date_setter, Date_index)
			create splitsym_setter.make (Current)
			value_setter_vector.force (splitsym_setter, Symbol_index)
			create split_setter
			value_setter_vector.force (split_setter, Split_index)
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

	close_tuple (t: STOCK_SPLIT)
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
				product.put (l, current_symbol.twin)
			else
				l := product @ current_symbol
			end
			l.extend (t)
		ensure then
			tuple_in_product: product.has (current_symbol) and
				(product @ current_symbol).has (t)
		end

	tuple_maker_execute
		do
			tuple_maker.execute
		end

	tuple_maker_product: STOCK_SPLIT
		do
			Result := tuple_maker.product
		end

feature {NONE} -- Innapplicable

	create_product
		do
		end

	add_tuple (t: STOCK_SPLIT)
		do
		end

feature {NONE} -- Tuple field-key constants

	Date_index: INTEGER = 1
	Symbol_index: INTEGER = 2
	Split_index: INTEGER = 3
	Last_index: INTEGER = 3

invariant

	these_fields_not_void:
		tuple_maker /= Void and value_setters /= Void and product /= Void

end -- STOCK_SPLIT_SEQUENCE
