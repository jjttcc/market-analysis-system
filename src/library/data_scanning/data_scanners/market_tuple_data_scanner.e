indexing
	description: "DATA_SCANNER that scans MARKET_TUPLE fields"
	date: "$Date$";
	revision: "$Revision$"

class MARKET_TUPLE_DATA_SCANNER inherit

	DATA_SCANNER
		redefine
			product, tuple_maker, open_tuple, close_tuple
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
