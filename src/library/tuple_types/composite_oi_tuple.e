indexing
	description: "Composite tuple with volume and open interest";
	date: "$Date$";
	revision: "$Revision$"

class COMPOSITE_OI_TUPLE inherit

	COMPOSITE_VOLUME_TUPLE

feature -- Access

	open_interest: INTEGER

feature {COMPOSITE_TUPLE_FACTORY} -- Element change

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
