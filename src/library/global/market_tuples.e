indexing
	description: "An instance of each instantiable MARKET_TUPLE class"
	author: "Jim Cochrane"
	date: "$Date$";
	note: "@@This class does not depend on any specialized classes and %
		%can probably be cleanly moved to the ma_library cluster."
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MARKET_TUPLES inherit

	CLASSES [MARKET_TUPLE]
		rename
			instances as tuple_instances, description as tuple_description, 
			instance_with_generator as tuple_with_generator,
			names as tuple_names
		redefine
			tuple_instances
		end

feature -- Access

	instances_and_descriptions: ARRAYED_LIST [PAIR [MARKET_TUPLE, STRING]] is
			-- An instance and description of each effective MARKET_TUPLE class
		local
			pair: PAIR [MARKET_TUPLE, STRING]
			now: DATE_TIME
		once
			create Result.make_filled (Largest_index)
			create now.make_now
			create pair.make (create {STOCK_SPLIT}, "Stock split")
			Result.put_i_th (pair, Stock_split_index)
			create pair.make (create {SIMPLE_TUPLE}.make (now, now.date, 0),
				"Single-value tuple")
			Result.put_i_th (pair, Simple_tuple_index)
			create pair.make (create {MARKET_POINT}.make,
				"Market tuple that functions as a point in a line")
			Result.put_i_th (pair, Market_point_index)
			create pair.make (create {BASIC_MARKET_TUPLE}.make,
				"Market tuple with date-time, open, high, low, close fields")
			Result.put_i_th (pair, Basic_market_tuple_index)
			create pair.make (create {BASIC_VOLUME_TUPLE}.make,
				 "Market tuple with date-time, open, high, low, close, %
				 %volume fields")
			Result.put_i_th (pair, Basic_volume_tuple_index)
			create pair.make (create {BASIC_OPEN_INTEREST_TUPLE}.make,
				 "Market tuple with date-time, open, high, low, close, %
				 %volume, open-interest fields")
			Result.put_i_th (pair, Basic_open_interest_tuple_index)
			create pair.make (create {COMPOSITE_TUPLE}.make,
				"Market tuple with date-time, open, high, low, close fields %
				%that is composed of smaller-duration tuples")
			Result.put_i_th (pair, Composite_tuple_index)
			create pair.make (create {COMPOSITE_VOLUME_TUPLE}.make,
				"Market tuple with date-time, open, high, low, close, %
				%volume fields that is composed of smaller-duration tuples")
			Result.put_i_th (pair, Composite_volume_tuple_index)
			create pair.make (create {COMPOSITE_OI_TUPLE}.make,
				"Market tuple with date-time, open, high, low, close, %
				%volume, and open-interest fields that is composed of %
				%smaller-duration tuples")
			Result.put_i_th (pair, Composite_oi_tuple_index)
		end

	tuple_instances: ARRAYED_LIST [MARKET_TUPLE] is
		once
			Result := Precursor
		end

	stock_split: MARKET_TUPLE is
		do
			Result := (instances_and_descriptions @ Stock_split_index).left
		end

	simple_tuple: MARKET_TUPLE is
		do
			Result := (instances_and_descriptions @ Simple_tuple_index).left
		end

	market_point: MARKET_TUPLE is
		do
			Result := (instances_and_descriptions @ Market_point_index).left
		end

	basic_market_tuple: MARKET_TUPLE is
		do
			Result := (instances_and_descriptions @
				Basic_market_tuple_index).left
		end

	basic_volume_tuple: MARKET_TUPLE is
		do
			Result := (instances_and_descriptions @
				Basic_volume_tuple_index).left
		end

	basic_open_interest_tuple: MARKET_TUPLE is
		do
			Result := (instances_and_descriptions @
				Basic_open_interest_tuple_index).left
		end

	composite_tuple: MARKET_TUPLE is
		do
			Result := (instances_and_descriptions @ Composite_tuple_index).left
		end

	composite_volume_tuple: MARKET_TUPLE is
		do
			Result := (instances_and_descriptions @
				Composite_volume_tuple_index).left
		end

	composite_oi_tuple: MARKET_TUPLE is
		do
			Result := (instances_and_descriptions @
				Composite_oi_tuple_index).left
		end

	Stock_split_index: INTEGER is 1

	Simple_tuple_index: INTEGER is 2

	Market_point_index: INTEGER is 3

	Basic_market_tuple_index: INTEGER is 4

	Basic_volume_tuple_index: INTEGER is 5

	Basic_open_interest_tuple_index: INTEGER is 6

	Composite_tuple_index: INTEGER is 7

	Composite_volume_tuple_index: INTEGER is 8

	Composite_oi_tuple_index: INTEGER is 9

	Largest_index: INTEGER is
		once
			Result := Composite_oi_tuple_index
		end

end
