indexing
	description:
		"Abstraction for an envelope - a symmetrical set of %
		%curves parallel to a curve.  A common example is Bollinger bands.";
	detailed_description:
		"Each curve in the set of symmetrical curves, as well as the original %
		%curve, is represented as a MARKET_FUNCTION.  position_factor %
		%specifies ... !!!"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class ENVELOPE inherit

	FUNCTION_GROUP
		rename
			make as fg_make
		end

creation

	make

feature -- Initialization

	make (main_function: MARKET_FUNCTION; n: INTEGER; pos_factor: REAL) is
			-- `n' specifies the number of pairs of parallel functions.
		do
		ensure
			functions_created: count = n * 2 + 1
			primary_function_set: primary_function = main_function
			pos_factor_set: position_factor = pos_factor
		end

feature -- Access

	primary_function: MARKET_FUNCTION is
		do
			Result := first
		end

	position_factor: REAL
			-- The value used to position each pair of parallel curves

end -- class ENVELOPE
