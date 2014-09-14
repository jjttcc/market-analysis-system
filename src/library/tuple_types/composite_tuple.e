note
	description:
		"A tuple that is created from a sequence of tuples of smaller %
		%duration, such as a weekly tuple from (usually 5) daily tuples";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class COMPOSITE_TUPLE inherit

	BASIC_TRADABLE_TUPLE
		export {COMPOSITE_TUPLE_FACTORY}
			begin_editing, end_editing, set, set_open, set_close, set_high,
			set_low
		redefine
			end_date
		end

creation

	make

feature -- Access

	first: TRADABLE_TUPLE
			-- First (chronologically) tuple used to create Current

	last: TRADABLE_TUPLE
			-- Last (chronologically) tuple used to create Current

	end_date: DATE
		do
			Result := last.date_time.date
		end

feature {COMPOSITE_TUPLE_FACTORY} -- Status setting

	set_first (arg: TRADABLE_TUPLE)
			-- Set first to `arg'.
		require
			arg /= Void
		do
			first := arg
		ensure
			first_set: first = arg and first /= Void
		end

	set_last (arg: TRADABLE_TUPLE)
			-- Set last to `arg'.
		require
			arg /= Void
		do
			last := arg
		ensure
			last_set: last = arg and last /= Void
		end

invariant

	never_edited: editing = False
	first_last_time_relationships: first /= Void and last /= Void implies
									first.date_time <= last.date_time
	firstdate_gt_date: first /= Void and date_time /= Void implies
									first.date_time >= date_time

end -- class COMPOSITE_TUPLE
