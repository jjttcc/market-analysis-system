indexing
	description:
		"A linear analyzer that processes one target list and uses a %
		%start_date_time and left offset"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

deferred class ONE_VARIABLE_LINEAR_ANALYZER inherit

	LINEAR_ANALYZER
		redefine
			start
		end

feature -- Access

	left_offset: INTEGER
			-- The largest offset used by an operator component to operate
			-- on an element of the target data sequence (input.output)
			-- before the current cursor position.  This is needed to ensure
			-- that an invalid cursor position is never accessed.  For
			-- example, if one of the operator components (the operator
			-- itself or, recursively, one of its operands) will, in its
			-- execute routine, access the position 5 elements before (to
			-- the left of) the current cursor position and no other
			-- component will access a position further left than this,
			-- left_offset should be set to 5.  Note that access to the right
			-- of the current cursor is not supported (left_offset cannot be
			-- negative).

	start_date_time: DATE_TIME is
			-- Date/time specifying which trading period to begin the
			-- analysis of market data
		deferred
		end

feature {NONE} -- Basic operations

	start is
		local
			i: INTEGER
		do
			from
				target.start
			until
				target.exhausted or
				target.item.date_time >= start_date_time
			loop
				target.forth
			end
			if left_offset > 0 then
				-- Adjust target cursor to the right `left_offset' positions
				-- so that the left offset used by the operator will
				-- not cause an invalid position to be accessed.
				from
					i := 0
				until
					i = left_offset or target.exhausted
				loop
					target.forth
					i := i + 1
				end
			end
		ensure then
			date_not_earlier: not target.exhausted implies
							target.item.date_time >= start_date_time
			offset_constraint:
				not target.exhausted implies target.index >= left_offset
		end

end -- class ONE_VARIABLE_LINEAR_ANALYZER
