indexing
	description:
		"A tuple that is created from a sequence of tuples of smaller %
		%duration, such as a weekly tuple from (usually 5) daily tuples";
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class COMPOSITE_TUPLE inherit

	BASIC_MARKET_TUPLE
		export {COMPOSITE_TUPLE_FACTORY}
			begin_editing, end_editing, set, set_open, set_close, set_high,
			set_low
		redefine
			make
		end

creation

	make

feature -- Initialization

	make is
		do
			-- Set first and last
			Precursor
		end

feature -- Access

	first: MARKET_TUPLE
			-- First (chronologically) tuple used to create Current

	last: MARKET_TUPLE
			-- Last (chronologically) tuple used to create Current

feature {COMPOSITE_TUPLE_FACTORY} -- Element change

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
