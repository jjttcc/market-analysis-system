indexing
	description: "Composite tuple with volume and open interest";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class COMPOSITE_OI_TUPLE inherit

	COMPOSITE_VOLUME_TUPLE

	OPEN_INTEREST_TUPLE
		undefine
			end_date, make
		end

feature -- Access

	open_interest: INTEGER

feature {COMPOSITE_TUPLE_FACTORY} -- Status setting

	set_open_interest (arg: INTEGER) is
			-- Set open_interest to `arg'.
		require
			arg /= Void
		do
			open_interest := arg
		ensure
			open_interest_set: open_interest = arg and open_interest /= Void
		end

end -- class COMPOSITE_OI_TUPLE
