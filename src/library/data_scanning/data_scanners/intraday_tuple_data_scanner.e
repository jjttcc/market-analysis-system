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
			auxiliary_check_date_time
		end

creation

	make

feature -- Access

	period_type: TIME_PERIOD_TYPE
			-- Period type of data - determined while scanning - Void if
			-- input data stream is empty

feature {NONE} -- Implementation

	auxiliary_check_date_time (t: BASIC_MARKET_TUPLE) is
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
		ensure
			period_type_set_if_start_input_and_not_first_record: (start_input
				and old last_date_time /= Void) implies period_type /= Void
		end

--!!!!:
	check_date_time_db (t: BASIC_MARKET_TUPLE) is
		local
			duration: DATE_TIME_DURATION
			ptypes: expanded PERIOD_TYPE_FACILITIES
		do
--			Precursor (t)
			if
				period_type = Void and last_date_time /= Void and then
				t.date_time.date.is_equal (last_date_time.date)
			then
print ("a" + "%N")
				create duration.make (0, 0, 0,
					t.date_time.hour - last_date_time.hour,
					t.date_time.minute - last_date_time.minute, 0)
				check
					ptypes.valid_duration (duration)
				end
				period_type := ptypes.period_type_with_duration (duration)
				if period_type = Void then
print ("b" + "%N")
					ptypes.add_non_standard_period_type (duration)
					period_type := ptypes.period_type_with_duration (duration)
				end
				check
					period_type_exists: period_type /= Void
				end
			else
print ("c" + "%N")
if last_date_time = Void then
	print ("[0] last_date_time is void" + "%N")
end
if period_type = Void then
	print ("[0] period_type is void" + "%N")
end
--				check
--					per_type_exists_or_no_last_time:
--						period_type /= Void or last_time = Void
--					else_period_type_set_if_last_time: last_time /= Void implies
--						period_type /= Void
--				end
			end
if last_date_time = Void then
	print ("[1] last_date_time is void" + "%N")
end
if period_type = Void then
	print ("[1] period_type is void" + "%N")
end
			check
				before_period_type_set_if_last_date_time: last_date_time /= Void implies
					period_type /= Void
			end
if last_date_time = Void then
	print ("[2] last_date_time is void" + "%N")
end
if period_type = Void then
	print ("[2] period_type is void" + "%N")
end
			if last_date_time = Void then
				print ("OOOP-OOOP: t.date_time was void!" + "%N")
			end
		ensure
			period_type_set_if_start_input_and_not_first_record: start_input
				implies (old last_date_time /= Void implies period_type /= Void)
		end

end -- class INTRADAY_TUPLE_DATA_SCANNER
