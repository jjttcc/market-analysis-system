indexing
	description: "DATA_SCANNER that scans MARKET_TUPLE fields"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
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

	make (prod: like product; in: like input;
			tm: like tuple_maker; vs: like value_setters) is
		require
			args_not_void: in /= Void and tm /= Void and vs /= Void and
							prod /= Void
			vs_not_empty: not vs.empty
		do
			data_scanner_make (in, tm, vs, "%T", "%N")
			product := prod
		ensure
			set: input = in and tuple_maker = tm and
				value_setters = vs and product = prod and
				field_separator.is_equal ("%T") and
				record_separator.is_equal ("%N")
		end

feature -- Access

	product: SIMPLE_FUNCTION [BASIC_MARKET_TUPLE]

	tuple_maker: BASIC_TUPLE_FACTORY

feature {FACTORY} -- Status setting

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
			check_date_time (t)
			check_and_fix_prices (t)
			t.end_editing
		ensure then
			not t.editing
		end

feature {NONE} -- Implementation

	check_and_fix_prices (t: BASIC_MARKET_TUPLE) is
			-- Check `t's prices and fix them if they are not valid.
		local
			s: STRING
		do
			if not t.price_relationships_correct then
				!!s.make (100)
				s.append ("Error in prices for tuple, date: ")
				s.append (t.date_time.date.out)
				s.append (", time: ")
				s.append (t.date_time.time.out)
				if t.open_available then
					s.append (", values (o, h, l, c): ")
					s.append (t.open.value.out)
					s.append (", ")
				else
					s.append (", values (h, l, c): ")
				end
				s.append (t.high.value.out)
				s.append (", ")
				s.append (t.low.value.out)
				s.append (", ")
				s.append (t.close.value.out)
				t.fix_price_relationships
				error_list.extend (s)
			end
		end

	check_date_time (t: BASIC_MARKET_TUPLE) is
		local
			s: STRING
		do
			if
				last_date_time /= Void and not (t.date_time > last_date_time)
			then
				!!s.make (0)
				s.append ("Error in date - date for current item: ")
				s.append (t.date_time.out)
				s.append (", date for last item: ")
				s.append (last_date_time.out)
				error_list.extend (s)
			end
			last_date_time := t.date_time
		end

	last_date_time: DATE_TIME
			-- date/time of last tuple

end -- class MARKET_TUPLE_DATA_SCANNER
