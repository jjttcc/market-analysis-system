indexing
	description:
		"Abstraction for an envelope - a symmetrical set of %
		%curves parallel to a curve.  A common example is Bollinger bands.";
	detailed_description:
		"Each curve in the set of symmetrical curves, as well as the original %
		%curve, is represented as a TRADABLE_FUNCTION.  position_factor %
		%specifies ... "
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class ENVELOPE inherit

	FUNCTION_GROUP
		rename
			make as fg_make
		end

creation

	make

feature -- Initialization

	make (main_function: TRADABLE_FUNCTION; n: INTEGER; pos_factor: DOUBLE) is
			-- `n' specifies the number of pairs of parallel functions.
		do
		ensure
			functions_created: count = n * 2 + 1
			primary_function_set: primary_function = main_function
			pos_factor_set: position_factor = pos_factor
		end

feature -- Access

	primary_function: TRADABLE_FUNCTION is
		do
			Result := first
		end

	position_factor: DOUBLE
			-- The value used to position each pair of parallel curves

end -- class ENVELOPE
