indexing
	description: "A tradable market entity, such as a stock or commodity";
	date: "$Date$";
	revision: "$Revision$"

class TRADABLE inherit

	SIMPLE_FUNCTION

feature -- Access

	indicators: LIST [MARKET_FUNCTION]

	indicator_groups: HASH_TABLE [LIST [MARKET_FUNCTION], STRING]

	weekly_data: LIST [MARKET_TUPLE] is -- !!!What type should this really be?
		do
			--stub
		end
	-- etc.

end -- class TRADABLE
