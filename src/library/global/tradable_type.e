indexing
	description: "Enumerated tradable types"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class TRADABLE_TYPE inherit

	ENUMERATED

create

	make_stock, make_derivative

create {ENUMERATED}

	make

feature {NONE} -- Initialization

	make_stock is
		do
			value_index := stock
		end
	
	make_derivative is
		do
			value_index := derivative
		end

feature -- Access

	stock, derivative: INTEGER is unique

	value_set: INTEGER_INTERVAL is
			-- Allowable values
		once
			create Result.make (stock, derivative)
		end

	name_set: ARRAY [STRING] is
			-- Names corresponding to `value_set'
		once
			create Result.make (stock, derivative)
			Result.put ("Stock", stock)
			Result.put ("Derivative", derivative)
		end

invariant

	values_valid: valid_value (stock) and valid_value (derivative)
	item_choices: item = stock or item = derivative

end
