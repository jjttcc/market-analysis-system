indexing
	description:
		"Abstraction that provides services for analysis of market data"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MARKET_ANALYSIS inherit

feature -- Access

	slope (c: CHAIN [MARKET_TUPLE]): REAL is
			-- Approximation of slope or rate of change of `c' at its
			-- current index
		require
			valid_position: not c.off
		do
			Result := slope_at (c, c.index)
		end

	slope_at (c: CHAIN [MARKET_TUPLE]; i: INTEGER): REAL is
			-- Approximation of slope or rate of change of `c' at the point
			-- (list element) specified by `i'
		require
			c.valid_index (i)
		local
			line1, line2: MARKET_LINE
			p1, p2, p3: expanded MARKET_POINT
			mt: MARKET_TUPLE
		do
			if i > 1 then
				mt := c.i_th (i - 1)
			else
				-- Beginning of list: use first, since previous doesn't exist.
				mt := c.i_th (i)
			end
			p1.set_x_y_date (i - 1, mt.value, mt.date_time)
			mt := c.i_th (i)
			p2.set_x_y_date (i, mt.value, mt.date_time)
			if i < c.count then
				mt := c.i_th (i + 1)
			else
				-- End of list: use last, since next doesn't exist.
				mt := c.i_th (i)
			end
			p3.set_x_y_date (i + 1, mt.value, mt.date_time)
			!!line1.make (p1, p2)
			!!line2.make (p2, p3)
			Result := (line1.slope + line2.slope) / 2
		end

end -- class MARKET_ANALYSIS
