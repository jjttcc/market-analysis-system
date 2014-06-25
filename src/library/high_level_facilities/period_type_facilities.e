note
	description: "General facilities relevant to TIME_PERIOD_TYPEs"
	note1: "All TIME_PERIOD_TYPEs are immutable."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class

	PERIOD_TYPE_FACILITIES

inherit

	TIME_PERIOD_TYPE_CONSTANTS

	GENERIC_SORTING [TIME_PERIOD_TYPE, INTEGER]
		rename
			duplicates as sorted_duplicates
		export
			{NONE} all
			{ANY} is_sorted_ascending
		end

feature -- Access - Period-type indexes

	one_minute: INTEGER = 1
			-- 1-minute index for `period_type_names'
	two_minute: INTEGER = 2
			-- 2-minute index for `period_type_names'
	five_minute: INTEGER = 3
			-- 5-minute index for `period_type_names'
	ten_minute: INTEGER = 4
			-- 10-minute index for `period_type_names'
	fifteen_minute: INTEGER = 5
			-- 15-minute index for `period_type_names'
	twenty_minute: INTEGER = 6
			-- 20-minute index for `period_type_names'
	thirty_minute: INTEGER = 7
			-- 30-minute index for `period_type_names'
	hourly: INTEGER = 8
			-- Hourly index for `period_type_names'
	daily: INTEGER = 9
			-- Daily index for `period_type_names'
	weekly: INTEGER = 10
			-- Weekly index for `period_type_names'
	monthly: INTEGER = 11
			-- Monthly index for `period_type_names'
	quarterly: INTEGER = 12
			-- Quarterly index for `period_type_names'
	yearly: INTEGER = 13
			-- Yearly index for `period_type_names'

feature -- Access

	all_period_types: LINKED_SET [TIME_PERIOD_TYPE]
			-- All time period types
		do
			create Result.make
			Result.fill (period_types.linear_representation)
		ensure
			exists: Result /= Void
		end

	standard_period_types: LINKED_LIST [TIME_PERIOD_TYPE]
			-- All "standard" period types (e.g., excluding 3-minute,
			-- 4-minute, etc. types)
		local
			indexes: LINEAR [INTEGER]
		do
			from
				indexes := standard_period_type_indexes.linear_representation
				create Result.make
				indexes.start
			until
				indexes.exhausted
			loop
				Result.extend (period_type_at_index (indexes.item))
				indexes.forth
			end
		ensure
			exists: Result /= Void
			corresponds_to_standard_period_type_indexes: Result.count =
				standard_period_type_indexes.count
		end

	period_type_at_index (i: INTEGER): TIME_PERIOD_TYPE
			-- Time period type at period-type index `i'
		require
			valid_index: i >= one_minute and i <= yearly
		do
			Result := period_types.item (period_type_names @ i)
		ensure
			exists: Result /= Void
		end

	period_types: HASH_TABLE [TIME_PERIOD_TYPE, STRING]
			-- All time period types used by the system, indexed by name
		note
			once_status: global
		local
			i: INTEGER
			keys: ARRAY [STRING]
		once
			create Result.make (1)
			from
				keys := non_intraday_period_types.current_keys
				i := 1
			until
				i = keys.count + 1
			loop
				Result.extend (non_intraday_period_types @ (keys @ i), keys @ i)
				i := i + 1
			end
			from
				keys := intraday_period_types.current_keys
				i := 1
			until
				i = keys.count + 1
			loop
				Result.extend (intraday_period_types @ (keys @ i), keys @ i)
				i := i + 1
			end
		ensure
			exists: Result /= Void
		end

	non_intraday_period_types: HASH_TABLE [TIME_PERIOD_TYPE, STRING]
			-- All time period types used by the system, indexed by name,
			-- whose duration is greater than or equal to a day.
		note
			once_status: global
		local
			type: TIME_PERIOD_TYPE
			tbl: HASH_TABLE [TIME_PERIOD_TYPE, STRING]
		once
			create tbl.make (3)
			type := new_standard_period_type (daily)
			tbl.extend (type, type.name)
			type := new_standard_period_type (weekly)
			tbl.extend (type, type.name)
			type := new_standard_period_type (monthly)
			tbl.extend (type, type.name)
			type := new_standard_period_type (quarterly)
			tbl.extend (type, type.name)
			type := new_standard_period_type (yearly)
			tbl.extend (type, type.name)
			Result := tbl
		ensure
			exists: Result /= Void
		end

	intraday_period_types: HASH_TABLE [TIME_PERIOD_TYPE, STRING]
			-- All intraday period types used by the system, indexed by name,
			-- whose duration is less than a day.
		note
			once_status: global
		local
			type: TIME_PERIOD_TYPE
			tbl: HASH_TABLE [TIME_PERIOD_TYPE, STRING]
		once
			create tbl.make (3)
			type := new_standard_period_type (one_minute)
			tbl.extend (type, type.name)
			intraday_period_type_names.force (type.name, one_minute)
			type := new_standard_period_type (two_minute)
			tbl.extend (type, type.name)
			intraday_period_type_names.force (type.name, two_minute)
			type := new_standard_period_type (five_minute)
			tbl.extend (type, type.name)
			intraday_period_type_names.force (type.name, five_minute)
			type := new_standard_period_type (ten_minute)
			tbl.extend (type, type.name)
			intraday_period_type_names.force (type.name, ten_minute)
			type := new_standard_period_type (fifteen_minute)
			tbl.extend (type, type.name)
			intraday_period_type_names.force (type.name, fifteen_minute)
			type := new_standard_period_type (twenty_minute)
			tbl.extend (type, type.name)
			intraday_period_type_names.force (type.name, twenty_minute)
			type := new_standard_period_type (thirty_minute)
			tbl.extend (type, type.name)
			intraday_period_type_names.force (type.name, thirty_minute)
			type := new_standard_period_type (hourly)
			tbl.extend (type, type.name)
			intraday_period_type_names.force (type.name, hourly)
			Result := tbl
		ensure
			exists: Result /= Void
		end

	period_types_in_order: PART_SORTED_SET [TIME_PERIOD_TYPE]
			-- All time period types sorted in ascending order by
			-- duration.
		note
			once_status: global
		once
			create Result.make
			Result.fill (all_period_types)
		ensure
			exists: Result /= Void
			sorted: is_sorted_ascending (Result)
		end

	period_type_names: ARRAY [STRING]
			-- The name of each element of `period_types' in ascending
			-- order by duration (except that the names of any
			-- non-standard period types are appended to the end)
		note
			once_status: global
		local
			tpt: TIME_PERIOD_TYPE
			duration: DATE_TIME_DURATION
			t: HASH_TABLE [TIME_PERIOD_TYPE, STRING]
		once
			-- Force intraday_period_type_names to be created.
			t := intraday_period_types
			create Result.make_empty    -- (See intraday_period_type_names)
			create duration.make (0, 0, 0, 0, 1, 0)
			create tpt.make (duration)
			Result := intraday_period_type_names.twin
			Result.force (tpt.daily_name, daily)
			Result.force (tpt.weekly_name, weekly)
			Result.force (tpt.monthly_name, monthly)
			Result.force (tpt.quarterly_name, quarterly)
			Result.force (tpt.yearly_name, yearly)
		ensure
			exists: Result /= Void
			constant_named_types_correspond_to_index:
				equal (period_types.item (Result @ hourly).name, hourly_name)
				equal (period_types.item (Result @ daily).name, daily_name)
				equal (period_types.item (Result @ weekly).name, weekly_name)
				equal (period_types.item (Result @ monthly).name, monthly_name)
				equal (period_types.item (Result @ quarterly).name,
					quarterly_name)
				equal (period_types.item (Result @ yearly).name, yearly_name)
		end

	intraday_period_type_names: ARRAY [STRING]
		note
			once_status: global
		once
--!!!!Overcome an apparent bug running in estudio, where a failed 'check occurs:
--			create Result.make (1, 1)
-- make_empty does not trigger the bug:
create Result.make_empty
		ensure
			exists: Result /= Void
		end

	standard_period_type_indexes: ARRAY [INTEGER]
			-- All standard TIME_PERIOD_TYPE indexes in order:
			-- one_minute .. yearly
		note
			once_status: global
		once
			Result := <<one_minute, two_minute, five_minute, ten_minute,
				fifteen_minute, twenty_minute, thirty_minute, hourly,
				daily, weekly, monthly, quarterly, yearly>>
		ensure
			exists: Result /= Void
			bounds_definition: Result.lower = 1 and
				Result.lower = one_minute and Result.upper = yearly
			first_item_one_minute: Result.item (1) = one_minute
			last_item_yearly: Result.item (Result.upper) = yearly
		end

	period_type_with_duration (d: DATE_TIME_DURATION): TIME_PERIOD_TYPE
			-- Period type whose duration matches `d' - Void if there
			-- is no such period type.
		require
			d_exists: d /= Void
			valid_duration: valid_duration (d)
		do
			Result := closest_period_type_for_duration (d)
			if Result /= Void and then not equal (Result.duration, d) then
				Result := Void
			end
		ensure
			durations_match_if_found: Result /= Void implies
				equal (Result.duration, d)
		end

	closest_period_type_for_duration (d: DATE_TIME_DURATION):
		TIME_PERIOD_TYPE
			-- Period type whose duration is greater than or equal to,
			-- and most closely matches, `d'
		require
			d_exists: d /= Void
			valid_duration: valid_duration (d)
		local
			types: LINEAR [TIME_PERIOD_TYPE]
		do
			from
				types := period_types_in_order
				types.start
			until
				Result /= Void or else types.exhausted
			loop
				if types.item.duration >= d then
					Result := types.item
				end
				types.forth
			end
		ensure
			exists_if_not_greater_than_largest_period_type:
				period_type_at_index (yearly).duration <= d implies
				Result /= Void
			larger_or_equal: Result /= Void implies Result.duration >= d
		end

feature -- Status report

	duration_is_intraday (d: DATE_TIME_DURATION): BOOLEAN
			-- Is `d' an intraday duration?
		require
			d_exists: d /= Void
		do
			Result := d.day = 0 and d.month = 0 and d.year = 0
		ensure
			Result = (d.day = 0 and d.month = 0 and d.year = 0)
		end

	valid_duration (d: DATE_TIME_DURATION): BOOLEAN
			-- Is `d' a valid duration for a time-period type?
		require
			d_exists: d /= Void
		local
			t: TIME_PERIOD_TYPE
			types: ARRAY [TIME_PERIOD_TYPE]
			i: INTEGER
		do
			if duration_is_intraday (d) then
				-- Currently, all intraday durations are considered valid.
				Result := True
			else
				-- `d' is non-intraday - so it's valid if it matches a
				-- standard non-intraday duration.
				t := period_types @ (period_type_names @ daily)
				types := <<
					period_types @ t.daily_name,
					period_types @ t.weekly_name,
					period_types @ t.monthly_name,
					period_types @ t.quarterly_name,
					period_types @ t.yearly_name
				>>
				from
					i := types.lower
				until
					Result or else i > types.upper
				loop
					t := types @ i
					Result := equal (t.duration, d)
					i := i + 1
				end
			end
		end

	standard_period_type (t: TIME_PERIOD_TYPE): BOOLEAN
			-- Is `t' a standard period type?
		local
			indexes: ARRAY [INTEGER]
			cur_t: TIME_PERIOD_TYPE
			i: INTEGER
		do
			if t.intraday then
				indexes := <<one_minute, two_minute, five_minute, ten_minute,
					fifteen_minute, twenty_minute, thirty_minute, hourly>>
				from
					i := indexes.lower
				until
					Result or else i > indexes.upper
				loop
					cur_t := period_types @ (period_type_names @ (indexes @ i))
					Result := equal (cur_t, t)
					i := i + 1
				end
			else
				Result := True
			end
		ensure
			true_if_not_intraday: not t.intraday implies Result
		end

	period_types_correct: BOOLEAN
			-- Do all period types have the correct state?
		local
			ns_types: LINKED_SET [TIME_PERIOD_TYPE]
			type_pairs: ARRAY [PAIR [TIME_PERIOD_TYPE, INTEGER]]
			pair: PAIR [TIME_PERIOD_TYPE, INTEGER]
			i: INTEGER
			indexes: LINEAR [INTEGER]
		do
			Result := True
			ns_types := all_period_types
			from
				indexes := standard_period_type_indexes.linear_representation
--!!!!Overcome bug (See intraday_period_type_names) - replace:
--create type_pairs.make (standard_period_type_indexes.lower,
--	standard_period_type_indexes.upper)
--     with:
				create type_pairs.make_empty
				indexes.start
			until
				indexes.exhausted
			loop
				type_pairs.force(create {PAIR [TIME_PERIOD_TYPE, INTEGER]}.make(
					period_types @ (period_type_names @ indexes.item),
					indexes.item), indexes.item)
				indexes.forth
			end
			from
				i := type_pairs.lower
			until
				not Result or else i > type_pairs.upper
			loop
				pair := type_pairs @ i
				Result := standard_period_type_correct (pair.first, pair.second)
				ns_types.prune (pair.first)
				i := i + 1
			end
			if Result then
				-- Check the non-standard period types.
				from
					ns_types.start
				until
					not Result or else ns_types.exhausted
				loop
					Result := non_standard_period_type_correct (ns_types.item)
					ns_types.forth
				end
			end
		end

feature -- Basic operations

	add_non_standard_period_type (d: DATE_TIME_DURATION)
			-- Add a "non-standard" period type with duration `d'.
		require
			d_exists: d /= Void
			d_is_intraday: duration_is_intraday (d)
			no_period_type_for_d: period_type_with_duration (d) = Void
			no_seconds: d.second = 0
		local
			t: TIME_PERIOD_TYPE
		do
			create t.make (d)
			-- Since these 'lists' are actually once functions, the new datum
			-- needs to be appended to them as if they were attributes.
			check
				not intraday_period_types.has (t.name)
			end
			intraday_period_types.extend (t, t.name)
			if not period_types.has (t.name) then
				period_types.extend (t, t.name)
			end
			period_type_names.force (t.name, period_type_names.upper + 1)
			intraday_period_type_names.force (t.name,
				intraday_period_type_names.upper + 1)
			if not period_types_in_order.has (t) then
				period_types_in_order.extend (t)
			end
		ensure
			period_type_for_d: period_type_with_duration (d) /= Void
		end

feature {NONE} -- Implementation

	non_standard_period_type_correct (t: TIME_PERIOD_TYPE): BOOLEAN
			-- Is the non-standard period type `t' valid?
		require
			p_exists: t /= Void
		local
			ref_t: TIME_PERIOD_TYPE
		do
			-- non-intraday non-standard types are not allowed.
			Result := t.intraday
			if Result then
				create ref_t.make (t.duration)
				-- The current scheme can't determine if the duration for
				-- a non-standard period type has changed (since it needs
				-- to be used to create the reference type), but it is
				-- possible to check that, assuming that the duration has
				-- not changed, the name has also not changed:
				Result := equal (t, ref_t)
			end
		end

	standard_period_type_correct (t: TIME_PERIOD_TYPE; type_index: INTEGER):
		BOOLEAN
			-- Is `t' in a correct state for a standard period type
			-- of `type_index'?
		require
			valid_type_index: standard_period_type_indexes.has (type_index)
			t_exists: t /= Void
		do
			Result := equal (t, new_standard_period_type (type_index))
		ensure
			Result = equal (t, new_standard_period_type (type_index))
		end

	new_standard_period_type (type_index: INTEGER): TIME_PERIOD_TYPE
			-- A new 'standard' period type based on `type_index'
		require
			valid_type_index: standard_period_type_indexes.has (type_index)
		local
			duration: DATE_TIME_DURATION
		do
			inspect
				type_index
			when one_minute then
				create duration.make (0, 0, 0, 0, 1, 0)
				check duration.minute = 1 end
				create Result.make (duration)
			when two_minute then
				create duration.make (0, 0, 0, 0, 2, 0)
				check duration.minute = 2 end
				create Result.make (duration)
			when five_minute then
				create duration.make (0, 0, 0, 0, 5, 0)
				check duration.minute = 5 end
				create Result.make (duration)
			when ten_minute then
				create duration.make (0, 0, 0, 0, 10, 0)
				check duration.minute = 10 end
				create Result.make (duration)
			when fifteen_minute then
				create duration.make (0, 0, 0, 0, 15, 0)
				check duration.minute = 15 end
				create Result.make (duration)
			when twenty_minute then
				create duration.make (0, 0, 0, 0, 20, 0)
				check duration.minute = 20 end
				create Result.make (duration)
			when thirty_minute then
				create duration.make (0, 0, 0, 0, 30, 0)
				check duration.minute = 30 end
				create Result.make (duration)
			when hourly then
				create duration.make (0, 0, 0, 1, 0, 0)
				check duration.hour = 1 end
				create Result.make (duration)
			when daily then
				create duration.make (0, 0, 1, 0, 0, 0)
				check duration.day = 1 end
				create Result.make (duration)
			when weekly then
				create duration.make (0, 0, 7, 0, 0, 0)
				check duration.day = 7 end
				create Result.make (duration)
			when monthly then
				create duration.make (0, 1, 0, 0, 0, 0)
				check duration.month = 1 end
				create Result.make (duration)
			when quarterly then
				create duration.make (0, 3, 0, 0, 0, 0)
				check duration.month = 3 end
				create Result.make (duration)
			when yearly then
				create duration.make (1, 0, 0, 0, 0, 0)
				check duration.year = 1 end
				create Result.make (duration)
			end
		ensure
			exists: Result /= Void
		end

invariant

	period_types_immutable: period_types_correct
	period_type_lists_correspond: all_period_types.count = period_types.count
	period_type_lists_correspond: period_types.count =
		intraday_period_types.count + non_intraday_period_types.count
	period_type_name_lists_correspond:
		period_type_names.count = period_types.count and
		intraday_period_type_names.count = intraday_period_types.count
	std_indexes_bounds: standard_period_type_indexes.lower = 1 and
				standard_period_type_indexes.lower = one_minute and
				standard_period_type_indexes.upper = yearly
				standard_period_type_indexes.count = yearly
	first_std_index_one_minute:
		standard_period_type_indexes.item (1) = one_minute
	last_std_index_yearly: standard_period_type_indexes.item (
		standard_period_type_indexes.upper) = yearly

end
