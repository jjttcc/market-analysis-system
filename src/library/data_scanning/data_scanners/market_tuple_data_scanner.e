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

feature -- Access

	product: TRADABLE [BASIC_MARKET_TUPLE]

	tuple_maker: BASIC_TUPLE_FACTORY

feature -- Status report

	arg_used: BOOLEAN is false

feature {FACTORY} -- Element change

	set_product_instance (arg: TRADABLE [BASIC_MARKET_TUPLE]) is
			-- Set product_instance to `arg'.
			-- This will be used to set `product' when execute is called
			-- instead of instantiating it.  Note that execute will
			-- reset product_instance to Void.
		require
			arg /= Void
		do
			product_instance := arg
		ensure
			product_instance_set: product_instance = arg and
				product_instance /= Void
		end

feature {FACTORY}

	product_instance: TRADABLE [BASIC_MARKET_TUPLE]

feature {NONE} -- Hook method implementations

	create_product is
		do
			if product_instance /= Void then
				product := product_instance
				product_instance := Void
			else
				check
					need_to_redesign_a_bit: false
					--!!!Probably need a mechanism to make sure
					--!!!product_instance is never Void
				end
			end
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
