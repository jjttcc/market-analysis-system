note
	description: "Composite tuple with volume and open interest";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class COMPOSITE_OI_TUPLE inherit

	COMPOSITE_VOLUME_TUPLE

	OPEN_INTEREST_TUPLE
		undefine
			end_date, make
		end

creation

	make

feature -- Access

	open_interest: DOUBLE

feature {COMPOSITE_TUPLE_FACTORY} -- Status setting

	set_open_interest (arg: DOUBLE)
			-- Set open_interest to `arg'.
		do
			open_interest := arg
		ensure
			open_interest_set: dabs (open_interest - arg) < Epsilon
		end

end -- class COMPOSITE_OI_TUPLE
