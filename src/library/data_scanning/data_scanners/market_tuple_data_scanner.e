indexing
	description: "DATA_SCANNER that scans MARKET_TUPLE fields"
	date: "$Date$";
	revision: "$Revision$"

class MARKET_TUPLE_DATA_SCANNER inherit

	DATA_SCANNER
		rename
			make as data_scanner_make
		export {NONE}
			data_scanner_make
		redefine
			product, tuple_maker, open_tuple, close_tuple
		end

creation

	make

feature

	make (prod: like product; in_file: like input_file;
			tm: like tuple_maker; vs: like value_setters) is
		require
			args_not_void: in_file /= Void and tm /= Void and vs /= Void and
							prod /= Void
			in_file_readable: in_file.exists and in_file.is_open_read
			vs_not_empty: not vs.empty
		do
			data_scanner_make (in_file, tm, vs, "%T", "%N")
			product := prod
		ensure
			set: input_file = in_file and tuple_maker = tm and
				value_setters = vs and product = prod and
				field_separator.is_equal ("%T") and
				record_separator.is_equal ("%N")
		end

feature -- Access

	product: SIMPLE_FUNCTION [BASIC_MARKET_TUPLE]

	tuple_maker: BASIC_TUPLE_FACTORY

feature -- Status report

	arg_used: BOOLEAN is false

feature {FACTORY} -- Element change

	set_product (arg: like product) is
			-- Set product to `arg'.
		require
			arg /= Void
		do
			product := arg
		ensure
			product_set: product = arg and product /= Void
		end

feature {NONE} -- Hook method implementations

	create_product is
		do
		end

	open_tuple (t: BASIC_MARKET_TUPLE) is
		do
			t.begin_editing
		ensure then
			t.editing
		end

	close_tuple (t: BASIC_MARKET_TUPLE) is
		do
			t.end_editing
		ensure then
			not t.editing
		end

end -- class MARKET_TUPLE_DATA_SCANNER
