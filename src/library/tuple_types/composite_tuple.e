indexing
	description:
		"A tuple that is created from a sequence of tuples of smaller %
		%duration, such as a weekly tuple from (usually 5) daily tuples";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class COMPOSITE_TUPLE inherit

	BASIC_MARKET_TUPLE
		export {COMPOSITE_TUPLE_FACTORY}
			begin_editing, end_editing, set, set_open, set_close, set_high,
			set_low
		redefine
			end_date
		end

creation

	make

feature -- Access

	first: MARKET_TUPLE
			-- First (chronologically) tuple used to create Current

	last: MARKET_TUPLE
			-- Last (chronologically) tuple used to create Current

	end_date: DATE is
		do
			Result := last.date_time.date
		end

feature {COMPOSITE_TUPLE_FACTORY} -- Status setting

	set_first (arg: MARKET_TUPLE) is
			-- Set first to `arg'.
		require
			arg /= Void
		do
			first := arg
		ensure
			first_set: first = arg and first /= Void
		end

	set_last (arg: MARKET_TUPLE) is
			-- Set last to `arg'.
		require
			arg /= Void
		do
			last := arg
		ensure
			last_set: last = arg and last /= Void
		end

invariant

	never_edited: editing = false
	first_last_time_relationships: first /= Void and last /= Void implies
									first.date_time <= last.date_time
	firstdate_gt_date: first /= Void and date_time /= Void implies
									first.date_time >= date_time

end -- class COMPOSITE_TUPLE
