indexing
	description: "";
	date: "$Date$";
	revision: "$Revision$"

class DATE_SETTER inherit

	VALUE_SETTER

feature {NONE}

	do_set (stream: IO_MEDIUM; tuple: MARKET_TUPLE) is
		do
			--Stub!!!
			--!!!Note:  Use a default expected format for date in this
			--class and define descendants to extract other formats.
		end

end -- class DATE_SETTER
