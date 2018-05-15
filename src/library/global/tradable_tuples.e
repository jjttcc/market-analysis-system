note
	description: "An instance of each instantiable TRADABLE_TUPLE class"
	author: "Jim Cochrane"
	date: "$Date$";
	note1: "@@This class does not depend on any specialized classes and %
		%can probably be cleanly moved to the ma_library cluster."
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class TRADABLE_TUPLES inherit

	CLASSES [TRADABLE_TUPLE]
		rename
			instances as tuple_instances, description as tuple_description, 
			instance_with_generator as tuple_with_generator,
			names as tuple_names
		redefine
			tuple_instances
		end

feature -- Access

	instances_and_descriptions: ARRAYED_LIST [PAIR [TRADABLE_TUPLE, STRING]]
			-- An instance and description of each effective
			-- TRADABLE_TUPLE class
		local
			pair: PAIR [TRADABLE_TUPLE, STRING]
			now: DATE_TIME
		once
			create Result.make_filled (Largest_index)
			create now.make_now
			create pair.make (create {STOCK_SPLIT}, "Stock split")
			Result.put_i_th (pair, Stock_split_index)
			create pair.make (create {SIMPLE_TUPLE}.make (now, now.date, 0),
				"Single-value tuple")
			Result.put_i_th (pair, Simple_tuple_index)
			create pair.make (create {TRADABLE_POINT}.make,
				"Tradable tuple that functions as a point in a line")
			Result.put_i_th (pair, tradable_point_index)
			create pair.make (create {BASIC_TRADABLE_TUPLE}.make,
				"Tradable tuple with date-time, open, high, low, close fields")
			Result.put_i_th (pair, Basic_tradable_tuple_index)
			create pair.make (create {BASIC_VOLUME_TUPLE}.make,
				 "Tradable tuple with date-time, open, high, low, close, %
				 %volume fields")
			Result.put_i_th (pair, Basic_volume_tuple_index)
			create pair.make (create {BASIC_OPEN_INTEREST_TUPLE}.make,
				 "Tradable tuple with date-time, open, high, low, close, %
				 %volume, open-interest fields")
			Result.put_i_th (pair, Basic_open_interest_tuple_index)
			create pair.make (create {COMPOSITE_TUPLE}.make,
				"Tradable tuple with date-time, open, high, low, close fields %
				%that is composed of smaller-duration tuples")
			Result.put_i_th (pair, Composite_tuple_index)
			create pair.make (create {COMPOSITE_VOLUME_TUPLE}.make,
				"Tradable tuple with date-time, open, high, low, close, %
				%volume fields that is composed of smaller-duration tuples")
			Result.put_i_th (pair, Composite_volume_tuple_index)
			create pair.make (create {COMPOSITE_OI_TUPLE}.make,
				"Tradable tuple with date-time, open, high, low, close, %
				%volume, and open-interest fields that is composed of %
				%smaller-duration tuples")
			Result.put_i_th (pair, Composite_oi_tuple_index)
		end

	tuple_instances: ARRAYED_LIST [TRADABLE_TUPLE]
		once
			Result := Precursor
		end

	stock_split: TRADABLE_TUPLE
		do
			Result := (instances_and_descriptions @ Stock_split_index).left
		end

	simple_tuple: TRADABLE_TUPLE
		do
			Result := (instances_and_descriptions @ Simple_tuple_index).left
		end

	tradable_point: TRADABLE_TUPLE
		do
			Result := (instances_and_descriptions @ tradable_point_index).left
		end

	basic_tradable_tuple: TRADABLE_TUPLE
		do
			Result := (instances_and_descriptions @
				Basic_tradable_tuple_index).left
		end

	basic_volume_tuple: TRADABLE_TUPLE
		do
			Result := (instances_and_descriptions @
				Basic_volume_tuple_index).left
		end

	basic_open_interest_tuple: TRADABLE_TUPLE
		do
			Result := (instances_and_descriptions @
				Basic_open_interest_tuple_index).left
		end

	composite_tuple: TRADABLE_TUPLE
		do
			Result := (instances_and_descriptions @ Composite_tuple_index).left
		end

	composite_volume_tuple: TRADABLE_TUPLE
		do
			Result := (instances_and_descriptions @
				Composite_volume_tuple_index).left
		end

	composite_oi_tuple: TRADABLE_TUPLE
		do
			Result := (instances_and_descriptions @
				Composite_oi_tuple_index).left
		end

	Stock_split_index: INTEGER = 1

	Simple_tuple_index: INTEGER = 2

	tradable_point_index: INTEGER = 3

	Basic_tradable_tuple_index: INTEGER = 4

	Basic_volume_tuple_index: INTEGER = 5

	Basic_open_interest_tuple_index: INTEGER = 6

	Composite_tuple_index: INTEGER = 7

	Composite_volume_tuple_index: INTEGER = 8

	Composite_oi_tuple_index: INTEGER = 9

	Largest_index: INTEGER
		note
			once_status: global
		once
			Result := Composite_oi_tuple_index
		end

end
