note
	description: "Composite tuple with volume and open interest";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class COMPOSITE_OI_TUPLE inherit

	COMPOSITE_VOLUME_TUPLE

	OPEN_INTEREST_TUPLE
		undefine
			end_date, make
		end

creation

	make

feature -- Access

	open_interest: REAL

feature {COMPOSITE_TUPLE_FACTORY} -- Status setting

	set_open_interest (arg: REAL)
			-- Set open_interest to `arg'.
		do
			open_interest := arg
		ensure
			open_interest_set: rabs (open_interest - arg) < Epsilon
		end

end -- class COMPOSITE_OI_TUPLE
