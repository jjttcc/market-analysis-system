indexing
	description: "DATA_SCANNER that scans MARKET_TUPLE fields"
	date: "$Date$";
	revision: "$Revision$"

class MARKET_TUPLE_DATA_SCANNER inherit

	DATA_SCANNER
		redefine
			product, tuple_maker, open_tuple, close_tuple
		end

creation

	make

feature -- Initialization

	make (in_file: like input_file; tm: like tuple_maker;
			vs: like value_setters; field_sep, record_sep: STRING) is
		require
			args_not_void: in_file /= Void and tm /= Void and vs /= Void and
				field_sep /= Void and record_sep /= Void
			in_file_readable: in_file.exists and in_file.is_open_read
			vs_not_empty: not vs.empty
		do
			input_file := in_file
			tuple_maker := tm
			value_setters := vs
			field_separator := field_sep
			record_separator := record_sep
		ensure
			set: input_file = in_file and tuple_maker = tm and
				value_setters = vs and field_separator = field_sep and
				record_separator = record_sep
		end

feature -- Access

	product: SIMPLE_FUNCTION [MARKET_TUPLE]

	tuple_maker: BASIC_TUPLE_FACTORY

feature -- Status report

	arg_used: BOOLEAN is false

feature {NONE} -- Hook method implementations

	create_product is
		do
			!!product.make (0)
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
