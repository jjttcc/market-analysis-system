indexing
	description: "MARKET_TUPLE_DATA_SCANNER for intraday data"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class INTRADAY_TUPLE_DATA_SCANNER inherit

	MARKET_TUPLE_DATA_SCANNER
		rename
			make as mtds_make
		redefine
			check_date_time
		end

creation

	make

feature -- Initialization

	make (prod: like product; in: like input;
		tm: like tuple_maker; vs: like value_setters;
		non_std_period_types: like allow_non_standard_period_types) is
--!!!!Remove 'allow_non_standard_period_types'
--!!!Remove its use from other classes that no longer need to use it.
		require
			args_not_void: in /= Void and tm /= Void and vs /= Void and
							prod /= Void
			vs_not_empty: not vs.is_empty
		do
			mtds_make (prod, in, tm, vs)
			allow_non_standard_period_types := non_std_period_types
		ensure
			set: input = in and tuple_maker = tm and
				value_setters = vs and product = prod and
				allow_non_standard_period_types = non_std_period_types
			non_strict: strict_error_checking = False
		end


feature -- Access

	period_type: TIME_PERIOD_TYPE
			-- Period type of data - determined while scanning - Void if
			-- input data stream is empty

--!!!Remove:
	allow_non_standard_period_types: BOOLEAN
			-- Are non-standard time-period types (e.g., 3-minute) allowed?

feature {NONE} -- Implementation

	check_date_time (t: BASIC_MARKET_TUPLE) is
		local
			duration: DATE_TIME_DURATION
			ptypes: expanded PERIOD_TYPE_FACILITIES
		do
			Precursor (t)
			if
				period_type = Void and last_time /= Void and
				t.date_time.date.is_equal (last_time.date)
			then
				create duration.make (0, 0, 0,
					t.date_time.hour - last_time.hour,
					t.date_time.minute - last_time.minute, 0)
				check
					ptypes.valid_duration (duration)
				end
				period_type := ptypes.period_type_with_duration (duration)
				if period_type = Void then
--!!!Remove the checking for 'allow_non_standard_period_types'
					if allow_non_standard_period_types then
						ptypes.add_non_standard_period_type (duration)
						period_type := ptypes.period_type_with_duration (
							duration)
					else
						period_type :=
							ptypes.closest_period_type_for_duration (duration)
					end
print ("check_date_time - period type was non-standard: " +
period_type.name + "%N")
--!!!Debugging - cleanup needed
				else
--!!!Debugging - cleanup needed
print ("check_date_time - period type with dur gave: " +
period_type.name + "%N")
				end
				check
					period_type_exists: period_type /= Void
				end
			end
			last_time := t.date_time
		ensure
			period_type_set_if_not_first_record: old last_time /= Void implies
				period_type /= Void
		end

	last_time: DATE_TIME

end -- class INTRADAY_TUPLE_DATA_SCANNER
