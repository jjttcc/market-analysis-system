note
	description: "TRADABLE_TUPLE_DATA_SCANNER for intraday data"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class INTRADAY_TUPLE_DATA_SCANNER inherit

	TRADABLE_TUPLE_DATA_SCANNER
		redefine
			auxiliary_check_date_time
		end

creation

	make

feature -- Access

	period_type: TIME_PERIOD_TYPE
			-- Period type of data - determined while scanning - Void if
			-- input data stream is empty

feature {NONE} -- Implementation

	auxiliary_check_date_time (t: BASIC_TRADABLE_TUPLE)
		local
			duration: DATE_TIME_DURATION
			ptypes: expanded PERIOD_TYPE_FACILITIES
		do
			if
				start_input and then period_type = Void and
				last_date_time /= Void and then
				t.date_time.date.is_equal (last_date_time.date)
			then
				-- Set the (intraday) period type.
				create duration.make (0, 0, 0,
					t.date_time.hour - last_date_time.hour,
					t.date_time.minute - last_date_time.minute, 0)
				check
					ptypes.valid_duration (duration)
				end
				period_type := ptypes.period_type_with_duration (duration)
				if period_type = Void then
					ptypes.add_non_standard_period_type (duration)
					period_type := ptypes.period_type_with_duration (duration)
				end
				check
					period_type_exists: period_type /= Void
				end
			end
		ensure then
			period_type_set_if_start_input_and_not_first_record: (start_input
				and old last_date_time /= Void) implies period_type /= Void
		end

end -- class INTRADAY_TUPLE_DATA_SCANNER
