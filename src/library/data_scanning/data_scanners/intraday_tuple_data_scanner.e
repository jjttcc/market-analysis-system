indexing
	description: "MARKET_TUPLE_DATA_SCANNER for intraday data"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class INTRADAY_TUPLE_DATA_SCANNER inherit

	MARKET_TUPLE_DATA_SCANNER
		redefine
			check_date_time
		end

creation

	make

feature -- Access

	period_type: TIME_PERIOD_TYPE
			-- Period type of data - determined while scanning - Void if
			-- input data stream is empty

feature {NONE} -- Implementation

	check_date_time (t: BASIC_MARKET_TUPLE) is
		local
			duration: DATE_TIME_DURATION
		do
			Precursor (t)
			if
				period_type = Void and last_time /= Void and
				t.date_time.date.is_equal (last_time.date)
			then
				create duration.make (0, 0, 0,
					t.date_time.hour - last_time.hour,
					t.date_time.minute - last_time.minute,
					t.date_time.second - last_time.second)
				create period_type.make (duration)
			end
			last_time := t.date_time
		end

	last_time: DATE_TIME

end -- class INTRADAY_TUPLE_DATA_SCANNER
