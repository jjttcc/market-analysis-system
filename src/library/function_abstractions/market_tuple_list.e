indexing
	description:
		"A list of objects that conform to MARKET_TUPLE that supports the %
		%concept of a type of trading period, such as daily, weekly, etc.";
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MARKET_TUPLE_LIST [G->MARKET_TUPLE] inherit

	ARRAYED_LIST [G]

creation

	make

feature

	sorted_by_date_time: BOOLEAN is
			-- Is Current sorted by date and time?
		do
			from
				Result := true
				start
				if not after then
					forth
				end
				check index = 2 or after end
			until
				after or not Result
			loop
				if
					not (i_th (index).date_time > i_th (index - 1).date_time)
				then
					Result := false
				end
			end
		end

invariant

	sorted_by_date_time: -- sorted_by_date_time
	--   (The above call is too inefficient to execute.)

end -- class MARKET_TUPLE_LIST
