indexing
	description:
		"Implementation of STOCK_SPLITS that loads its contents from a file"
	note:
		"It is assumed that the for each symbol that occurs in the input %
		%file, the splits in the file for that symbol are sorted by %
		%date ascending"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class STOCK_SPLIT_FILE inherit

	STOCK_SPLITS

	DATA_SCANNER
		rename
			make as ds_make_unused, field_separator as fs_unused,
			record_separator as rs_unused,
			set_record_separator as set_record_separator_unused,
			set_field_separator as set_field_separator_unused
		export
			{NONE} all
		redefine
			close_tuple, product, tuple_maker, add_tuple
		end

	INPUT_FILE
		rename
			name as file_name, make as ptf_make_unused,
			advance_to_next_field as if_advance_to_next_field,
			advance_to_next_record as if_advance_to_next_record
		export
			{NONE} all
			{ANY} file_name
		end

creation

	make

feature -- Access

	infix "@" (symbol: STRING): DYNAMIC_CHAIN [STOCK_SPLIT] is
		do
			if product.has (symbol) then
				Result := product @ symbol
			end
		end

feature {NONE} -- Initialization

	make (field_sep, record_sep, input_file_name: STRING) is
		require
			not_void: field_sep /= Void and input_file_name /= Void
			fsep_size_1: field_sep.count = 1
		do
			field_separator := field_sep
			record_separator := record_sep
			file_name := input_file_name
			open_file (file_name)
			!!product.make (100)
			!!tuple_maker
			make_value_setters
			if is_open_read then
				input := Current
				execute
			end
		ensure
			fs_set: field_separator.is_equal (field_sep)
			ss_set: record_separator.is_equal (record_sep)
			fname_set: file_name = input_file_name
			input_file_set_if_open: is_open_read implies input = Current
			value_setters_made: value_setters /= Void
			prod_tpmkr_made: product /= Void and tuple_maker /= Void
			rec_sep_is_newline: record_separator.is_equal ("%N")
		end

	open_file (fname: STRING) is
			-- Open file safely - if it fails, is_open_read is false.
		local
			open_failed: BOOLEAN
		do
			if not open_failed then
				make_open_read (file_name)
			end
		rescue
			open_failed := True
			retry
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

	product: HASH_TABLE [ DYNAMIC_CHAIN [STOCK_SPLIT], STRING]

feature {NONE} -- Implementation - utility

	index_vector: ARRAY [INTEGER] is
		once
			-- Hard code - make configurable later, if needed.
			Result := <<Date_index, Symbol_index, Split_index>>
		end

	make_value_setters is
		do
			!LINKED_LIST [VALUE_SETTER]!value_setters.make
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
			i := 1
			!!value_setter_vector.make (1, Last_index)
			!DAY_DATE_SETTER!setter.make
			value_setter_vector.put (setter, i)
			i := i + 1
			!SPLIT_SYMBOL_SETTER!setter.make (Current, field_separator @ 1)
			value_setter_vector.put (setter, i)
			i := i + 1
			!SPLIT_SETTER!setter
			value_setter_vector.put (setter, i)
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
			-- Add the new tuple to the list at `product' @ `current_symbol';
			-- create a list if not product.has (current_symbol)
		local
			l: DYNAMIC_CHAIN [STOCK_SPLIT]
			s: STRING
		do
			current_symbol.to_lower
			if not product.has (current_symbol) then
				!LINKED_LIST [STOCK_SPLIT]!l.make
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
		field_separator /= Void and tuple_maker /= Void and
		file_name /= Void and value_setters /= Void and product /= Void

end -- STOCK_SPLIT_FILE
